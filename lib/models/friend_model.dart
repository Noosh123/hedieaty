class FriendModel {
  final String userId; // Current user's ID
  final String friendId; // Friend's ID
  final String friendName; // Friend's name (optional but helpful)
  final String friendPhoneNumber; // Friend's phone number

  FriendModel({
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendPhoneNumber,
  });

  // Convert Firestore document to FriendModel
  factory FriendModel.fromFirestore(Map<String, dynamic> data) {
    return FriendModel(
      userId: data['userId'] ?? '',
      friendId: data['friendId'] ?? '',
      friendName: data['friendName'] ?? '',
      friendPhoneNumber: data['friendPhoneNumber'] ?? '',
    );
  }

  // Convert FriendModel to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendPhoneNumber': friendPhoneNumber,
    };
  }
}
