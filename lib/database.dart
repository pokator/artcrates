import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

//Database access and management methods.
//TODO: needs complete overhaul - use drift instead of sqflite.

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

  //DB Initialize
  Future<Database> _initDatabase() async {
    final String path = await getDatabasesPath();
    print(path);
    final String dbPath = join(path, 'art_crates.db');
    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }


  //TODO: Add other create commands for other supported websites.
  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE table_list (name VARCHAR(255) PRIMARY KEY)',
    );
    await db.execute(
      "CREATE TABLE 'All Links' (timestamp INTEGER PRIMARY KEY, link VARCHAR(255) UNIQUE, source VARCHAR(255))",
    );

    await db.execute(
      "CREATE TABLE 'twitter' (link VARCHAR(255) PRIMARY KEY, crates TEXT, image_links VARCHAR(255))",
    );
  }

  //Creating a table and adding it to the table_list (typically called when a new crate is being made)
  Future<bool> createNewTable(String table) async {
    print("Table creation time");
    print(table + " table name");
    final Database db = await database;
    var res = await db.rawQuery("SELECT name FROM table_list WHERE name='$table'");
    if(!res.isNotEmpty) {
      print("table creation statements");
      await db.execute("CREATE TABLE '$table' (timestamp INTEGER PRIMARY KEY);");
      await insert({'name': table}, 'table_list');

      List<Map<String, dynamic>> rows = await queryAllRows('table_list');
      print(rows.toString() + " new table list");
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

  //Deletion of a record from the entire database system. Given a timestamp.
  Future<int> completeDelete(int timestamp) async {
    final Database db = await database;
    //Get the link from all_links.
    String linkQuery = "SELECT link, source FROM 'All Links' WHERE timestamp = $timestamp;";
    List<Map<String, dynamic>> list = await db.rawQuery(linkQuery);
    //Crates separated by []
    String link = list[0]['link'];
    linkQuery = "SELECT crates FROM 'All Links' WHERE link = $link";
    list = await db.rawQuery(linkQuery);
    //Delete from source table
    db.delete(list[0]['source'], where: 'link = ?', whereArgs: [link]);

    //Deletion from the crates
    List<String> tableList = (list[0]['crates'] as String).split("[]");
    for (var element in tableList) {
      await db.delete(element, where: 'timestamp = ?', whereArgs: [timestamp]);
    }

    return await db.delete('All Links', where: 'timestamp = ?', whereArgs: [timestamp]);
  }

  //Deletion of a single record stored in a crate.
  Future<int> crateDelete(int id, String table) async {
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

    print(tableList.toString());

    for(Map<String, dynamic> table in tableList) {
        //receives a link
        List<Map<String, dynamic>> queryResult = await getTopImage(table['name']);
        //receives the link portion of the image location.

        if('FlkwOM6X0AEsJwP?format=jpg' != queryResult[0]['link']) {
          String query = "SELECT image_links FROM " + queryResult[0]['source'] + " WHERE link = '" + queryResult[0]['link'] + "'";
          print(query);
          List<Map<String, dynamic>> imageLinks = await db.rawQuery(query);
          print("${imageLinks.toString()} imageLinks length");

          //Image links are separated by []
          //THIS IS ONLY FOR TWITTER (FOR NOW)
          String images = imageLinks[0]['image_links'];
          Tuple2<String, String> result = Tuple2(table['name'], "https://pbs.twimg.com/media/${images.split("[]")[0]}&name=large");
          toReturn.add(result);
        } else {
          Tuple2<String, String> result = Tuple2(table['name'], "https://pbs.twimg.com/media/FlkwOM6X0AEsJwP?format=jpg&name=large");
          toReturn.add(result);
        }
    }

    return toReturn;
  }

  //Get the first link (from all links) for a particular crate.
  Future<List<Map<String, dynamic>>> getTopImage(String table) async {
    final Database db = await database;
    String topQuery = "SELECT timestamp FROM '$table' ORDER BY timestamp ASC LIMIT 1;";
    final List<Map<String, dynamic>> topTimestampResult = await db.rawQuery(topQuery);
    if(topTimestampResult.isEmpty) {
      return [{'link': 'FlkwOM6X0AEsJwP?format=jpg'}];
    } else {
      final int topTimestamp = topTimestampResult[0]['timestamp'];
      final linkQuery = "SELECT link, source FROM 'All Links' WHERE timestamp = $topTimestamp;";


      return await db.rawQuery(linkQuery);
    }
  }

  Future<int> getRowCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM table_list');
    return result[0]['COUNT(*)'] as int;
  }

}


