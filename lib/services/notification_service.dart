import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final CollectionReference _notificationsCollection =
  FirebaseFirestore.instance.collection('notifications');

  // Add a notification for a specific user
  Future<void> addNotification(String userId, NotificationModel notification) async {
    try {
      await _notificationsCollection.doc(userId).set({
        'notifications': FieldValue.arrayUnion([notification.toFirestore()])
      }, SetOptions(merge: true));
      print("Notification added successfully!");
    } catch (e) {
      print("Error adding notification: $e");
      rethrow;
    }
  }

  // Fetch notifications for a specific user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final doc = await _notificationsCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final notifications = doc['notifications'] as List<dynamic>;
        return notifications
            .map((data) => NotificationModel.fromFirestore(data as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print("Error fetching notifications: $e");
      rethrow;
    }
  }

  // Clear notifications after they are fetched
  Future<void> clearNotifications(String userId) async {
    try {
      await _notificationsCollection.doc(userId).update({
        'notifications': [],
      });
      print("Notifications cleared successfully!");
    } catch (e) {
      print("Error clearing notifications: $e");
      rethrow;
    }
  }
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    try {
      return _notificationsCollection.doc(userId).snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final notifications = snapshot['notifications'] as List<dynamic>;
          return notifications
              .map((data) => NotificationModel.fromFirestore(data as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
    } catch (e) {
      print("Error fetching notifications stream: $e");
      rethrow;
    }
  }


}
