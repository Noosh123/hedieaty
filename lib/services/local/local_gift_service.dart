import 'package:sqflite/sqflite.dart';
import 'local_database.dart';
import '../../models/gift_model.dart';

class LocalGiftService {
  final LocalDatabase _localDatabase = LocalDatabase();

  /// Add a gift to the local database
  Future<void> addGift(GiftModel gift) async {
    final db = await _localDatabase.database;

    await db.insert(
      'gifts',
      gift.toLocalDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all gifts for a specific event from the local database
  Future<List<GiftModel>> getGiftsByEventId(String eventId) async {
    final db = await _localDatabase.database;

    final List<Map<String, dynamic>> giftMaps = await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    return giftMaps.map((giftMap) => GiftModel.fromLocalDatabaseMap(giftMap)).toList();
  }

  /// Retrieve a specific gift by ID
  Future<GiftModel?> getGiftById(String id) async {
    final db = await _localDatabase.database;

    final List<Map<String, dynamic>> giftMaps = await db.query(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (giftMaps.isNotEmpty) {
      return GiftModel.fromLocalDatabaseMap(giftMaps.first);
    }
    return null;
  }

  /// Update a gift in the local database
  Future<void> updateGift(GiftModel gift) async {
    final db = await _localDatabase.database;

    await db.update(
      'gifts',
      gift.toLocalDatabaseMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  /// Delete a gift from the local database
  Future<void> deleteGift(String id) async {
    final db = await _localDatabase.database;

    await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
