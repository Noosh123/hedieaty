import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';

class FriendService {
  final CollectionReference _friendsCollection =
  FirebaseFirestore.instance.collection('friends');
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Add a friend relationship to Firestore
  Future<bool> addFriend({
    required String currentUserId,
    required String friendPhoneNumber,
  }) async {
    try {
      // Check if the user with the given phone number exists
      final query = await _usersCollection
          .where('phoneNumber', isEqualTo: friendPhoneNumber)
          .get();

      if (query.docs.isNotEmpty) {
        final friendDoc = query.docs.first;

        // Friend's data
        final String friendId = friendDoc.id;
        final String friendName = friendDoc['name'];

        // Check if this friend relationship already exists
        final checkQuery = await _friendsCollection
            .where('userId', isEqualTo: currentUserId)
            .where('friendId', isEqualTo: friendId)
            .get();

        if (checkQuery.docs.isEmpty) {
          // Add the relationship
          final FriendModel newFriend = FriendModel(
            userId: currentUserId,
            friendId: friendId,
            friendName: friendName,
            friendPhoneNumber: friendPhoneNumber,
          );

          await _friendsCollection.add(newFriend.toFirestore());
          return true; // Successfully added
        } else {
          print("Friend already exists.");
          return false; // Friend already exists
        }
      } else {
        print("User not found.");
        return false; // User doesn't exist
      }
    } catch (e) {
      print("Error adding friend: $e");
      rethrow;
    }
  }

  // Fetch friends of a user
  Stream<List<FriendModel>> getFriends(String currentUserId) {
    return _friendsCollection
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList());
  }
}