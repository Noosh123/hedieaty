import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String userId;
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

  // Convert EventModel to Local Database Map
  Map<String, dynamic> toLocalDatabaseMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'date': date.toIso8601String(), // Save date as ISO string
      'location': location,
      'description': description,
    };
  }

  // Convert Local Database Map to EventModel
  factory EventModel.fromLocalDatabaseMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      category: map['category'],
      date: DateTime.parse(map['date']), // Parse ISO string back to DateTime
      location: map['location'],
      description: map['description'],
    );
  }
  // CopyWith method for creating updated instances
  EventModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    DateTime? date,
    String? location,
    String? description,
  }) {
    return EventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }
}
