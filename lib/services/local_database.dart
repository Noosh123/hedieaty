import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();

  factory LocalDatabase() => _instance;

  static Database? _database;

  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create the events table
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        userId TEXT,
        name TEXT,
        category TEXT,
        date TEXT,
        location TEXT,
        description TEXT
      )
    ''');

    // Create the gifts table
    await db.execute('''
      CREATE TABLE gifts (
        id TEXT PRIMARY KEY,
        eventId TEXT,
        userId TEXT,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        image TEXT,
        status TEXT,
        pledgedBy TEXT,
        FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
