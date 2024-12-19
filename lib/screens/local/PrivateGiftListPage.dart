import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/screens/addGift.dart';
import 'package:hedieaty/services/local/local_gift_service.dart';

class PrivateGiftListPage extends StatefulWidget {
  final String eventId;

  const PrivateGiftListPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _PrivateGiftListPageState createState() => _PrivateGiftListPageState();
}

class _PrivateGiftListPageState extends State<PrivateGiftListPage> {
  final LocalGiftService _localGiftService = LocalGiftService();
  List<GiftModel> _gifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    setState(() => _isLoading = true);
    try {
      final gifts = await _localGiftService.getGiftsByEventId(widget.eventId);
      setState(() => _gifts = gifts);
    } catch (e) {
      print('Error loading gifts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGift(String giftId) async {
    try {
      await _localGiftService.deleteGift(giftId);
      _loadGifts(); // Refresh the gift list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting gift: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Private Gifts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle sorting logic
              if (value == 'name') {
                setState(() {
                  _gifts.sort((a, b) => a.name.compareTo(b.name));
                });
              } else if (value == 'category') {
                setState(() {
                  _gifts.sort((a, b) => a.category.compareTo(b.category));
                });
              } else if (value == 'status') {
                setState(() {
                  _gifts.sort((a, b) => a.status.compareTo(b.status));
                });
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              PopupMenuItem(
                value: 'category',
                child: Text('Sort by Category'),
              ),
              PopupMenuItem(
                value: 'status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gifts.isEmpty
          ? const Center(child: Text('No gifts found for this event'))
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          final isAvailable = gift.status == 'available';

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: gift.image.isNotEmpty
                    ? NetworkImage(gift.image)
                    : null,
                radius: 30,
                child: gift.image.isEmpty
                    ? const Icon(
                  Icons.card_giftcard,
                  size: 30,
                  color: Colors.white,
                )
                    : null,
                backgroundColor: gift.image.isEmpty
                    ? Colors.orange
                    : null,
              ),
              title: Text(gift.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${gift.category}'),
                  Text('Price: \$${gift.price.toStringAsFixed(2)}'),
                  Text(
                    isAvailable ? 'Available' : 'Pledged',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGift(
                          eventId: widget.eventId,
                          gift: gift,
                          isEdit: true,
                        ),
                      ),
                    );
                    _loadGifts(); // Refresh after editing
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                              'Are you sure you want to delete this gift?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await _deleteGift(gift.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateGift(
                  eventId: widget.eventId,
                  isEdit: false,
                ),
              ),
            );
            _loadGifts(); // Refresh after adding a new gift
          },
          child: const Text(
            'Add New Gift',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
