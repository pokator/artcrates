import 'package:artcrates/persistent_elements.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'crates.dart';
import 'all.dart';
import 'database.dart';
import 'feed.dart';

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

  await database.execute(
    "CREATE TABLE 'All Links' (timestamp INTEGER PRIMARY KEY, link VARCHAR(255), description VARCHAR(255), user VARCHAR(255), tags TEXT, num_images INTEGER, original_link VARCHAR(255))",
  );
  await database.execute(
    "CREATE TABLE table_list (name VARCHAR(255) PRIMARY KEY);"
  );
  await database.execute(
      "INSERT INTO table_list ('name') values (?);", ["All Links"]
  );
  // var tables = database.rawQuery('SELECT * FROM sqlite_master WHERE name="allLinks";');
  //
  // print("next line has the tables");
  // print(tables);
  await database.execute("INSERT INTO 'All Links' ('timestamp', 'link', 'description', 'user', 'tags', 'num_images', 'original_link') values (?, ?, ?, ?, ?, ?, ?)", [DateTime.now().millisecondsSinceEpoch.toString(), "https://pbs.twimg.com/media/FuL9AI4WIAULdBp?format=jpg&name=large", "夜蘭おめでとう〜！！！💙✨ #夜蘭生誕祭2023 #Genshinlmpact #Yelan", "@yoppigu3", "all", 1, "https://twitter.com/brocccolihater/status/1649158615956090880/photo/1"]);
  // print("executed.");
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
      // now check if the chosen page has already been built
      // if it hasn't, then it still is a SizedBox
      // if (_pages[index] is SizedBox) {
      //   if (index == 1) {
      //     _pages[index] = MyPage(
      //       1,
      //       "Page 02",
      //       MyKeys.getKeys().elementAt(index),
      //     );
      //   } else {
      //     _pages[index] = MyPage(
      //       1,
      //       "Page 03",
      //       MyKeys.getKeys().elementAt(index),
      //     );
      //   }
      // }
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

