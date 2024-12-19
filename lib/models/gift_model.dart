class GiftModel {
  final String id;
  final String eventId;
  final String userId; // User who created the gift
  final String name;
  final String description;
  final String category;
  final double price;
  final String image;
  final String status; // "available" or "pledged"
  final String? pledgedBy; // User who pledged the gift

  GiftModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.image,
    required this.status,
    this.pledgedBy,
  });

  // Convert Firestore document to GiftModel
  factory GiftModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return GiftModel(
      id: docId,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num).toDouble(),
      image: data['image'] ?? '',
      status: data['status'] ?? 'available',
      pledgedBy: data['pledgedBy'],
    );
  }

  // Convert GiftModel to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'image': image,
      'status': status,
      'pledgedBy': pledgedBy,
    };
  }
  // Convert GiftModel to Local Database Map
  Map<String, dynamic> toLocalDatabaseMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'image': image,
      'status': status,
      'pledgedBy': pledgedBy,
    };
  }

  // Convert Local Database Map to GiftModel
  factory GiftModel.fromLocalDatabaseMap(Map<String, dynamic> map) {
    return GiftModel(
      id: map['id'],
      eventId: map['eventId'],
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      image: map['image'],
      status: map['status'],
      pledgedBy: map['pledgedBy'],
    );
  }


}
