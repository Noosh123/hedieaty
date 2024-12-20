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

  final Color primaryColor = const Color(0xFFFF7B7B); // Soft coral
  final Color secondaryColor = const Color(0xFF98D7C2); // Mint green
  final Color accentColor = const Color(0xFFE2D1F9); // Light purple
  final Color goldAccent = const Color(0xFFFFD700); // Gold
  final Color backgroundColor = const Color(0xFFFFFAF0); // Cream

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Gifts for ${widget.eventName}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildEventDetails(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _gifts.isEmpty
              ? const Center(
            child: Text(
              'No gifts found for this event',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: _gifts.length,
              itemBuilder: (context, index) {
                final gift = _gifts[index];
                final isAvailable = gift.status == 'available';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, accentColor.withOpacity(0.2)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    key: Key('gift_$index'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: goldAccent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: gift.image.isNotEmpty ? NetworkImage(gift.image) : null,

                        child: gift.image.isEmpty
                            ? Icon(
                          Icons.card_giftcard,
                          color: primaryColor,
                          size: 28,
                        )
                            : null,
                        backgroundColor: gift.image.isEmpty ? primaryColor.withOpacity(0.1) : null,
                      ),
                    ),
                    title: Text(
                      gift.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category, size: 16, color: primaryColor),
                            const SizedBox(width: 4),
                            Text('Category: ${gift.category}'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 16, color: secondaryColor),
                            const SizedBox(width: 4),
                            Text('Price: \$${gift.price.toStringAsFixed(2)}'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: isAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAvailable ? 'Available' : 'Pledged',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_forward,
                        color: primaryColor,
                      ),
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
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.2), secondaryColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description, color: Colors.orange, size: 20.0),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.eventDescription,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 20.0),
              const SizedBox(width: 8),
              Text(
                widget.eventLocation,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.green, size: 20.0),
              const SizedBox(width: 8),
              Text(
                "Date: ${widget.eventDate.toLocal()}".split(' ')[1],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
