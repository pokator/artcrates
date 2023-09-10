import 'package:artcrates/persistent_elements.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'crates.dart';
import 'database.dart';

//Main page initialization.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MyDatabaseHelper helper = MyDatabaseHelper();
  final database = await helper.database;

  // Get list of table names in the database
  final tables = await database.query('sqlite_master',
      where: 'type = ?',
      whereArgs: ['table'],
      columns: ['name']).then((results) => results.map((result) => result['name'] as String).toList());

  // Drop tables not in the list
  for (final table in tables) {
    await database.execute("DROP TABLE IF EXISTS '$table'");
  }


  //For now - "all links table"
  //TODO: make tables relational based on photo source - add a column for source (twitter, pixiv, tumblr, etc)

  await database.execute(
    "CREATE TABLE 'All Links' (timestamp INTEGER PRIMARY KEY, link VARCHAR(255) UNIQUE, source VARCHAR(255))",
  );

  await database.execute(
    "CREATE TABLE 'twitter' (link VARCHAR(255) PRIMARY KEY, tags TEXT, image_links VARCHAR(255))",
  );

  await database.execute(
    "CREATE TABLE table_list (name VARCHAR(255) PRIMARY KEY);"
  );

  await database.execute(
      "CREATE TABLE supported_list (name VARCHAR(255) PRIMARY KEY);"
  );

  await database.execute(
      "INSERT INTO table_list ('name') values (?);", ["All Links"]
  );

  await database.execute(
      "INSERT INTO supported_list ('name') values (?);", ["twitter"]
  );

  await database.execute("INSERT INTO 'All Links' ('timestamp', 'link', 'source') values (?, ?, ?)", [DateTime.now().millisecondsSinceEpoch.toString(), "https://twitter.com/brocccolihater/status/1649158615956090880", "twitter"]);
  await database.execute("INSERT INTO 'twitter' ('link', 'tags', 'image_links') values (?, ?, ?)", ["https://twitter.com/brocccolihater/status/1649158615956090880", "ningguang[]beidou[]genshin", "FuL9AI4WIAULdBp?format=jpg"]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtCrates',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.black54,
      ),
      home: const MainScreen(title: 'ArtCrates'),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPage = 0;

  List<Widget> _pages = <Widget>[];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }
  final List<BottomNavigationBarItem> _items = [
    const BottomNavigationBarItem(
      icon: Icon(LineIcons.box),
      label: 'Crates',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.feed),
      label: 'Latest',
    ),
    const BottomNavigationBarItem(
      icon: Icon(LineIcons.images),
      label: 'All',
    )
  ];

  @override
  void initState() {
    super.initState();
    _selectedPage = 0;

    _pages = [
      const CratesPage(),
      // This avoid the other pages to be built unnecessarily
      const SizedBox(),
      const SizedBox(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: PersistentDrawer(),
      appBar: PersistentAppBar(),
      body: WillPopScope(
        onWillPop: () async {
          return !await Navigator.maybePop(
            MyKeys.getKeys()[_selectedPage].currentState!.context,
          );
        },
        child: IndexedStack(
          index: _selectedPage,
          children: _pages,
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.brown,
        currentIndex: _selectedPage,
        selectedIconTheme: const IconThemeData(
          color: Colors.black,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.deepOrangeAccent,
        ),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: _items,
      ),
    );
  }


}

class MyKeys {
  static final first = GlobalKey(debugLabel: 'crates');
  static final second = GlobalKey(debugLabel: 'feed');
  static final third = GlobalKey(debugLabel: 'all');

  static List<GlobalKey> getKeys() => [first, second, third];
}

