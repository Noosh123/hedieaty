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
          .map((doc) =>
          GiftModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print("Error fetching gifts: $e");
      rethrow;
    }
  }

  // Fetch a single gift by its ID
  Future<GiftModel?> getGiftById(String giftId) async {
    try {
      final doc = await _giftsCollection.doc(giftId).get();
      if (doc.exists) {
        return GiftModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null; // Gift not found
    } catch (e) {
      print("Error fetching gift by ID: $e");
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

  // Fetch all pledged gifts by a specific user
  Stream<List<GiftModel>> getPledgedGiftsByUser(String userId) {
    try {
      return _giftsCollection
          .where('pledgedBy', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) =>
          GiftModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print("Error fetching pledged gifts: $e");
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
