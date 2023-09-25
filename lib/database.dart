import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = path.join(await getDatabasesPath(), 'product_app.db');

    final Database database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            image TEXT
          )
        ''');

        db.execute('''
          CREATE TABLE reasons(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reason TEXT
          )
        ''');
      },
    );

    return database;
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.insert('products', product);
  }

  Future<int> insertReason(Map<String, dynamic> reason) async {
    final db = await instance.database;
    return await db.insert('reasons', reason);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }
}
