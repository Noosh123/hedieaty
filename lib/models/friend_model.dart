class FriendModel {
  final String userId;
  final String friendId;

  FriendModel({
    required this.userId,
    required this.friendId,
  });

  // Convert Firestore document to FriendModel
  factory FriendModel.fromFirestore(Map<String, dynamic> data) {
    return FriendModel(
      userId: data['userId'] ?? '',
      friendId: data['friendId'] ?? '',
    );
  }

  // Convert FriendModel to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'friendId': friendId,
    };
  }
}
