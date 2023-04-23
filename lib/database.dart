import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';


class MyDatabaseHelper {
  static final MyDatabaseHelper _instance = MyDatabaseHelper._();
  static Database? _database;

  MyDatabaseHelper._();

  factory MyDatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    final String path = await getDatabasesPath();
    print(path);
    final String dbPath = join(path, 'art_crates.db');
    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE table_list (name VARCHAR(255) PRIMARY KEY)',
    );
    await db.execute(
      "CREATE TABLE 'All Links' (timestamp INTEGER PRIMARY KEY, link VARCHAR(255), description VARCHAR(255), user VARCHAR(255), tags TEXT, num_images INTEGER, original_link VARCHAR(255))",
    );
  }

  Future<bool> createNewTable(String table) async {
    final Database db = await database;
    var res = await db.rawQuery("SELECT name FROM table_list WHERE name='$table'");
    if(!res.isNotEmpty) {
      await db.execute("CREATE TABLE '$table' (timestamp INTEGER PRIMARY KEY);");
      await insert({'name': table}, 'table_list');
      return true;
    }

    return false;
  }


  Future<int> insert(Map<String, dynamic> row, String table) async {
    final Database db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final Database db = await database;
    return await db.query(table);
  }

  Future<List<String>> getTableList() async {
    final Database db = await database;
    final result = await queryAllRows("table_list");
    List<String> toReturn = [];

    for(Map<String, dynamic> table in result) {
      if(table['name'] != "All Links") {
        toReturn.add(table['name']);
      }
    }

    return toReturn;
  }

  Future<int> update(Map<String, dynamic> row, String table) async {
    final Database db = await database;
    final int id = row['date'];
    return await db.update(table, row, where: 'timestamp = ?', whereArgs: [id]);
  }

  Future<int> delete(int id, String table) async {
    final Database db = await database;
    return await db.delete(table, where: 'timestamp = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> execute(String query) async {
    final Database db = await database;
    return await db.rawQuery(query);
  }

  //Utilizing Tuple2 structure - item1 corresponds to Crate Name, item2 to Link
  Future<List<Tuple2<String, String>>> getAllTopImages() async {
    final Database db = await database;
    final List<Map<String, dynamic>> tableList = await queryAllRows("table_list");
    List<Tuple2<String, String>> toReturn = [];

    for(Map<String, dynamic> table in tableList) {
        //receives a link
        final List<Map<String, dynamic>> queryResult = await getTopImage(table['name']);
        Tuple2<String, String> result = Tuple2(table['name'], queryResult[0]['link']);
        toReturn.add(result);
    }

    return toReturn;
  }

  Future<List<Map<String, dynamic>>> getTopImage(String table) async {
    final Database db = await database;
    String topQuery = "SELECT timestamp FROM '$table' ORDER BY timestamp ASC LIMIT 1;";
    final List<Map<String, dynamic>> topTimestampResult = await db.rawQuery(topQuery);
    if(topTimestampResult.isEmpty) {
      return [{'link': 'https://pbs.twimg.com/media/FlkwOM6X0AEsJwP?format=jpg&name=large'}];
    } else {
      final int topTimestamp = topTimestampResult[0]['timestamp'];
      final linkQuery = "SELECT link FROM 'All Links' WHERE timestamp = $topTimestamp;";
      return await db.rawQuery(linkQuery);
    }
  }

  Future<int> getRowCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM table_list');
    return (result[0]['COUNT(*)'] as int) ?? 0;
  }

}


