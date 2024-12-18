import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Add a new user to Firestore after sign-up
  Future<void> addUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore());
      print("User added successfully to Firestore!");
    } catch (e) {
      print("Error adding user: $e");
      rethrow;
    }
  }

  // Fetch user data by ID
  // Fetch user data by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id, // Add the document ID explicitly
        });
      }
      return null; // User not found
    } catch (e) {
      print("Error fetching user: $e");
      rethrow;
    }
  }


  // Update user profile details
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
      print("User profile updated successfully!");
    } catch (e) {
      print("Error updating user profile: $e");
      rethrow;
    }
  }
}
