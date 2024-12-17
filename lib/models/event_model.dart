import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String userId; // ID of the user who created the event
  final String name;
  final String category;
  final DateTime date;
  final String location;
  final String description;

  EventModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
  });

  // Convert Firestore document to EventModel
  factory EventModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return EventModel(
      id: docId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
    );
  }

  // Convert EventModel to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'date': date,
      'location': location,
      'description': description,
    };
  }
}
