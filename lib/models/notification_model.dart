import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String message;
  final DateTime timestamp;
  final String type; // "pledge" or "unpledge"
  final String fromUserId;
  final String eventId;
  final String giftId;

  NotificationModel({
    required this.message,
    required this.timestamp,
    required this.type,
    required this.fromUserId,
    required this.eventId,
    required this.giftId,
  });

  // Convert Firestore document to NotificationModel
  factory NotificationModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationModel(
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      fromUserId: data['fromUserId'] ?? '',
      eventId: data['eventId'] ?? '',
      giftId: data['giftId'] ?? '',
    );
  }

  // Convert NotificationModel to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'timestamp': timestamp,
      'type': type,
      'fromUserId': fromUserId,
      'eventId': eventId,
      'giftId': giftId,
    };
  }
}
