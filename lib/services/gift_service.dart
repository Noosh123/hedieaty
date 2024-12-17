import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';

class GiftService {
  final CollectionReference _giftsCollection =
  FirebaseFirestore.instance.collection('gifts');

  // Add a new gift to Firestore
  Future<void> addGift(GiftModel gift) async {
    try {
      await _giftsCollection.add(gift.toFirestore());
      print("Gift added successfully to Firestore!");
    } catch (e) {
      print("Error adding gift: $e");
      rethrow;
    }
  }

  // Fetch all gifts for a specific event
  Stream<List<GiftModel>> getGiftsForEvent(String eventId) {
    try {
      return _giftsCollection
          .where('eventId', isEqualTo: eventId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => GiftModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print("Error fetching gifts: $e");
      rethrow;
    }
  }

  // Update gift details (e.g., name, price, etc.)
  Future<void> updateGift(String giftId, Map<String, dynamic> data) async {
    try {
      await _giftsCollection.doc(giftId).update(data);
      print("Gift updated successfully!");
    } catch (e) {
      print("Error updating gift: $e");
      rethrow;
    }
  }

  // Pledge a gift
  Future<void> pledgeGift(String giftId, String userId) async {
    try {
      await _giftsCollection.doc(giftId).update({
        'status': 'pledged',
        'pledgedBy': userId,
      });
      print("Gift pledged successfully!");
    } catch (e) {
      print("Error pledging gift: $e");
      rethrow;
    }
  }

  // Unpledge a gift
  Future<void> unpledgeGift(String giftId) async {
    try {
      await _giftsCollection.doc(giftId).update({
        'status': 'available',
        'pledgedBy': null,
      });
      print("Gift unpledged successfully!");
    } catch (e) {
      print("Error unpledging gift: $e");
      rethrow;
    }
  }

  // Delete a gift
  Future<void> deleteGift(String giftId) async {
    try {
      await _giftsCollection.doc(giftId).delete();
      print("Gift deleted successfully!");
    } catch (e) {
      print("Error deleting gift: $e");
      rethrow;
    }
  }
}
