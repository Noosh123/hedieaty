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

  @override
  void initState() {
    super.initState();
    _isPledged = widget.gift.status == 'pledged';
  }

  Future<void> _sendNotification(String type) async {
    try {
      final currentUserId = _authService.currentUser!.uid;

      // Get details of the user and event
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

        // Send notification to the gift owner
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
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('Gift Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                      : const Icon(
                    Icons.card_giftcard,
                    size: 150,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Gift Name
                Row(
                  children: [
                    const Icon(Icons.label, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      widget.gift.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.gift.description.isNotEmpty
                            ? widget.gift.description
                            : 'No description available.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category
                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Category: ${widget.gift.category}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Price: \$${widget.gift.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pledge/Unpledge Button
                Center(
                  child: ElevatedButton.icon(
                    key: const Key('gift_pledge_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPledged ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
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
      ),
    );
  }
}
