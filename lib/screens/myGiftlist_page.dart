import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/screens/addGift.dart';
import 'package:hedieaty/services/gift_service.dart';

class MyGiftListPage extends StatefulWidget {
  final String eventId;
  final bool isUpcoming;

  MyGiftListPage({required this.eventId, required this.isUpcoming});

  @override
  _MyGiftListPageState createState() => _MyGiftListPageState();
}

class _MyGiftListPageState extends State<MyGiftListPage> {
  final GiftService _giftService = GiftService();
  List<GiftModel> _gifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  void _loadGifts() {
    _giftService.getGiftsForEvent(widget.eventId).listen((giftList) {
      setState(() {
        _gifts = giftList;
        _isLoading = false;
      });
    });
  }

  Future<void> _deleteGift(String giftId) async {
    await _giftService.deleteGift(giftId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gift deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Gift List'),
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
                    : const AssetImage('assets/default.png')
                as ImageProvider,
                radius: 30,
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
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGift(
                          eventId: widget.eventId,
                          gift: gift, // Pass the gift if editing
                          isEdit: true, // Set to true for editing
                        ),
                      ),
                    );

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
                              onPressed: () {
                                _deleteGift(gift.id);
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
            backgroundColor: widget.isUpcoming ? Colors.green : Colors.grey,
          ),
          onPressed: widget.isUpcoming
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateGift(
                  eventId: widget.eventId,
                  isEdit: false, // It's a new gift, so not editing
                ),
              ),
            );
          }
              : null, // Disable button if event is not upcoming
          child: const Text(
            'Add New Gift',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),

    );
  }
}
