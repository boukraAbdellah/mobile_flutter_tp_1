import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;
  static final table = 'favs';
  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnArtist = 'artist';
  static final columnDescription = 'description';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

// SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY,
  $columnTitle TEXT NOT NULL,
  $columnArtist TEXT NOT NULL,
  $columnDescription TEXT NOT NULL
)
''');
  }

// Helper methods
// Inserts a row in the database where each key in the Map is a column name
// and the value is the column value. The return value is the id of the
// inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<bool> exists(int id) async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> result = await db!.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
