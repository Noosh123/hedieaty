import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final CollectionReference _eventsCollection =
  FirebaseFirestore.instance.collection('events');

  // Add a new event to Firestore
  Future<void> addEvent(EventModel event) async {
    try {
      await _eventsCollection.add(event.toFirestore());
      print("Event added successfully to Firestore!");
    } catch (e) {
      print("Error adding event: $e");
      rethrow;
    }
  }

  // Fetch events created by a specific user
  Stream<List<EventModel>> getUserEvents(String userId) {
    try {
      return _eventsCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print("Error fetching user events: $e");
      rethrow;
    }
  }

  // Fetch only upcoming events (date >= current date)
  Stream<List<EventModel>> getUpcomingEvents() {
    try {
      return _eventsCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.now())
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print("Error fetching upcoming events: $e");
      rethrow;
    }
  }

  // Update event details
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _eventsCollection.doc(eventId).update(data);
      print("Event updated successfully!");
    } catch (e) {
      print("Error updating event: $e");
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
      print("Event deleted successfully!");
    } catch (e) {
      print("Error deleting event: $e");
      rethrow;
    }
  }
  // Fetch event details by eventId
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching event by ID: $e");
      rethrow;
    }
  }

}

