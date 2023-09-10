import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tuple/tuple.dart';
import 'database.dart';
import 'main.dart';

//The crates page.

class CratesPage extends StatefulWidget {
  const CratesPage({super.key});

  @override
  _CratesPageState createState() => _CratesPageState();
}


class _CratesPageState extends State<CratesPage> {
  final navigatorKey = MyKeys.getKeys().elementAt(0);
  final TextEditingController _nameController = TextEditingController();
  MyDatabaseHelper helper = MyDatabaseHelper();
  var data;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }
  @override
  void initState()  {
    super.initState();
    data = helper.getAllTopImages();
  }

  Future<void> _refresh() async {
    setState(() {
      data = helper.getAllTopImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (context, setState) {
                      return RefreshIndicator(
                          onRefresh: _refresh,
                          child: FutureBuilder<List<Tuple2<String, String>>>(
                            //TODO: convert to StreamBuilder
                            future: data,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState != ConnectionState.done) {
                                // While the future is loading, show a loading indicator
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                // If the future encountered an error, show an error message
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Text('Error: no data');
                              }
                              // Once the future is complete, show the data in a ListView
                              final pairs = snapshot.requireData;
                              return Scaffold(
                                body: GridView.builder(
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  itemCount: pairs.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => Crate(
                                                  pairs[index].item2, pairs[index].item1)));
                                        },
                                        child: Padding(padding: const EdgeInsets.all(10.0),
                                          child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 10),
                                                    borderRadius: BorderRadius.circular(30),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(pairs[index].item2),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      pairs[index].item1 == "allLinks"
                                                          ? "All Links"
                                                          : pairs[index].item1,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          shadows: [
                                                            Shadow(
                                                              color: Colors.black.withOpacity(0.7),
                                                              offset: const Offset(15, 15),
                                                              blurRadius: 100,
                                                            ),
                                                          ],
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 22.0),
                                                    )
                                                ),
                                              ]
                                          ),)
                                    );
                                    // );
                                  },
                                ),
                                floatingActionButton: FloatingActionButton(
                                  backgroundColor: Colors.amber,
                                  splashColor: Colors.brown,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          title: const Text('New Crate'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                TextField(
                                                  autofocus: true,
                                                  controller: _nameController,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Crate Name',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                String name = _nameController.text;
                                                _nameController.text = "";
                                                // Do something with the name here
                                                MyDatabaseHelper helper = MyDatabaseHelper();
                                                helper.createNewTable(name);
                                                // Refresh the future
                                                setState((){_refresh();});
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text('Create'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  tooltip: "Create a new crate",
                                  child: const Icon(LineIcons.plusCircle),
                                ),
                              );
                              }
                          ));
                    }
                );
            });
      },
    );
  }
}

class PhotoItem {
  final String image;
  final String name;

  PhotoItem(this.image, this.name);
}

class Crate extends StatelessWidget {
  Crate(this.link, this.name);

  final String link;
  final String name;

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        body: WillPopScope(
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight),
                Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                Image(
                  image: NetworkImage(link),
                ),
              ],
            ),
            onWillPop: () async {
              Navigator.pop(parentContext);
              return true;
            }));
  }
}
