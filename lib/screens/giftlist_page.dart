import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/gift_service.dart';
import 'giftdetails_page.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventDescription;
  final String eventLocation;
  final DateTime eventDate;
  final bool isUpcoming;

  const GiftListPage({
    Key? key,
    required this.eventId,
    required this.eventName,
    required this.eventDescription,
    required this.eventLocation,
    required this.eventDate,
    required this.isUpcoming,
  }) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftService _giftService = GiftService();
  final AuthService _authService = AuthService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('Gift List'),
      ),
      body: Column(
        children: [
          // Event Details Container
          _buildEventDetails(),
          // Gift List
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _gifts.isEmpty
              ? const Center(child: Text('No gifts found for this event'))
              : Expanded(
            child: ListView.builder(
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
                        Text(
                            'Price: \$${gift.price.toStringAsFixed(2)}'),
                        Text(
                          isAvailable ? 'Available' : 'Pledged',
                          style: TextStyle(
                            color: isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: isAvailable
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftDetailsPage(
                            gift: gift,
                          ),
                        ),
                      );
                    }
                        : null,
                    trailing: Icon(
                      Icons.circle,
                      color:
                      isAvailable ? Colors.green : Colors.yellow,
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: Colors.blue, size: 24.0),
              const SizedBox(width: 8),
              Text(
                widget.eventName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description, color: Colors.orange, size: 20.0),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.eventDescription,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: Colors.redAccent, size: 20.0),
              const SizedBox(width: 8),
              Text(
                widget.eventLocation,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.green, size: 20.0),
              const SizedBox(width: 8),
              Text(
                "Date: ${widget.eventDate.toLocal()}".split(' ')[0],
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
