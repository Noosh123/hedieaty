import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/models/notification_model.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/event_service.dart';
import 'package:hedieaty/services/gift_service.dart';
import 'package:hedieaty/services/notification_service.dart';
import 'package:hedieaty/services/user_service.dart';

class GiftDetailsPage extends StatefulWidget {
  final GiftModel gift;

  const GiftDetailsPage({Key? key, required this.gift}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final GiftService _giftService = GiftService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final EventService _eventService = EventService();

  bool _isPledged = false;

  final Color primaryColor = const Color(0xFFFF7B7B); // Soft coral
  final Color secondaryColor = const Color(0xFF98D7C2); // Mint green
  final Color accentColor = const Color(0xFFE2D1F9); // Light purple
  final Color goldAccent = const Color(0xFFFFD700); // Gold
  final Color backgroundColor = const Color(0xFFFFFAF0); // Cream

  @override
  void initState() {
    super.initState();
    _isPledged = widget.gift.status == 'pledged';
  }

  Future<void> _sendNotification(String type) async {
    try {
      final currentUserId = _authService.currentUser!.uid;

      final currentUser = await _userService.getUser(currentUserId);
      final event = await _eventService.getEventById(widget.gift.eventId);

      if (currentUser != null && event != null) {
        final notification = NotificationModel(
          message:
          '${currentUser.name} has ${type == "pledge" ? "pledged" : "unpledged"} the gift "${widget.gift.name}" for the event "${event.name}".',
          timestamp: DateTime.now(),
          type: type,
          fromUserId: currentUserId,
          eventId: widget.gift.eventId,
          giftId: widget.gift.id,
        );

        await _notificationService.addNotification(widget.gift.userId, notification);
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _togglePledge() async {
    final currentUserId = _authService.currentUser!.uid;

    if (_isPledged) {
      await _giftService.unpledgeGift(widget.gift.id);
      await _sendNotification('unpledge');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift unpledged successfully!')),
      );
    } else {
      await _giftService.pledgeGift(widget.gift.id, currentUserId);
      await _sendNotification('pledge');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift pledged successfully!')),
      );
    }

    setState(() {
      _isPledged = !_isPledged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Gift Details',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, accentColor.withOpacity(0.2)],
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gift Image
              Center(
                child: widget.gift.image.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.gift.image,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                )
                    : CircleAvatar(
                  radius: 75,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: const Icon(
                    Icons.card_giftcard,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gift Name
              _buildDetailRow(Icons.label, 'Name', widget.gift.name, primaryColor),

              // Description
              _buildDetailRow(
                Icons.description,
                'Description',
                widget.gift.description.isNotEmpty ? widget.gift.description : 'No description available.',
                secondaryColor,
              ),

              // Category
              _buildDetailRow(Icons.category, 'Category', widget.gift.category, goldAccent),

              // Price
              _buildDetailRow(Icons.monetization_on, 'Price', '\$${widget.gift.price.toStringAsFixed(2)}', accentColor),

              const SizedBox(height: 16),

              // Pledge/Unpledge Button
              Center(
                child: ElevatedButton.icon(
                  key: const Key('gift_pledge_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPledged ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _togglePledge,
                  icon: Icon(
                    _isPledged ? Icons.close : Icons.ads_click,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isPledged ? 'Unpledge' : 'Pledge',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
