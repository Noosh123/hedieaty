import 'package:sqflite/sqflite.dart';
import 'local_database.dart';
import '../../models/event_model.dart';

class LocalEventService {
  final LocalDatabase _localDatabase = LocalDatabase();

  /// Add an event to the local database
  Future<void> addEvent(EventModel event) async {
    final db = await _localDatabase.database;

    await db.insert(
      'events',
      event.toLocalDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieve all events from the local database
  Future<List<EventModel>> getAllEvents() async {
    final db = await _localDatabase.database;

    final List<Map<String, dynamic>> eventMaps = await db.query('events');

    return eventMaps.map((eventMap) => EventModel.fromLocalDatabaseMap(eventMap)).toList();
  }

  /// Retrieve a specific event by ID
  Future<EventModel?> getEventById(String id) async {
    final db = await _localDatabase.database;

    final List<Map<String, dynamic>> eventMaps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (eventMaps.isNotEmpty) {
      return EventModel.fromLocalDatabaseMap(eventMaps.first);
    }
    return null;
  }

  /// Update an event in the local database
  Future<void> updateEvent(EventModel event) async {
    final db = await _localDatabase.database;

    await db.update(
      'events',
      event.toLocalDatabaseMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Delete an event from the local database
  Future<void> deleteEvent(String id) async {
    final db = await _localDatabase.database;

    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
