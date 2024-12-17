import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';

class FriendService {
  final CollectionReference _friendsCollection =
  FirebaseFirestore.instance.collection('friends');

  // Add a friend relationship to Firestore
  Future<void> addFriend(String userId, String friendId) async {
    try {
      // Check if the friend relationship already exists
      final query = await _friendsCollection
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .get();

      if (query.docs.isEmpty) {
        await _friendsCollection.add({
          'userId': userId,
          'friendId': friendId,
        });
        print("Friend added successfully!");
      } else {
        print("Friend relationship already exists.");
      }
    } catch (e) {
      print("Error adding friend: $e");
      rethrow;
    }
  }

  // Fetch the list of friends for a user
  Stream<List<String>> getFriends(String userId) {
    try {
      return _friendsCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => doc['friendId'] as String).toList());
    } catch (e) {
      print("Error fetching friends: $e");
      rethrow;
    }
  }

  // Check if a user exists in the 'users' collection
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print("Error checking user existence: $e");
      rethrow;
    }
  }

  // Remove a friend relationship
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      final query = await _friendsCollection
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendId)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
      print("Friend removed successfully!");
    } catch (e) {
      print("Error removing friend: $e");
      rethrow;
    }
  }
}
