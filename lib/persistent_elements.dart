import 'package:artcrates/crates.dart';
import 'package:artcrates/database.dart';
import 'package:artcrates/link_parsing.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class PersistentDrawer extends StatefulWidget {
  const PersistentDrawer({super.key});

  @override
  PersistentDrawerState createState() => PersistentDrawerState();
}

class PersistentDrawerState extends State<PersistentDrawer> {
  final TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown,
            ),
            child: Text('PhotoCrates Menu'),
          ),
          ListTile(
            leading: const Icon(LineIcons.plusCircle),
            title: const Text('Add a Link'),
            onTap: () {
              buildDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(LineIcons.cog),
            title: const Text('Settings'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  //List<CrateOptions> _crateList = [];
  buildDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: const Text('Add a Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  autofocus: true,
                  controller: _linkController,
                  decoration: const InputDecoration(
                    hintText: 'Paste Link',
                  ),
                ),
                TagText(),
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
                String link = _linkController.text;
                List<String> list = TagBox().values;
                LinkParser parser = LinkParser(link, list);
                parser.getArt();

                // Do something with the name here
                // Refresh the future
                Navigator.of(context).pop(true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class TagText extends StatefulWidget {
  const TagText({super.key});

  @override
  TagBox createState() => TagBox();
}

class TagBox extends State<TagText> {
  MyDatabaseHelper helper = MyDatabaseHelper();
  TextEditingController crateController = TextEditingController();
  static List<String> _values = [];

  get values {
    return _values;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 230,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      onSubmitted: (entered) {
                        if (values.contains(entered.toLowerCase()) ||
                            entered.contains("All Links")) {
                          Fluttertoast.showToast(
                            msg: "Already chose that crate!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          setState(() {
                            values.add(entered.toLowerCase());
                          });
                          crateController.clear();
                        }
                      },
                      controller: crateController,
                      autofocus: true,
                      style: DefaultTextStyle.of(context).style.copyWith(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Crate it!",
                      )),
                  suggestionsCallback: (pattern) async {
                    if (pattern == '') {
                      return [];
                    }
                    List<String> list = await helper.getTableList();
                    List<String> ret = [];
                    for (String s in list) {
                      if (s.toLowerCase().contains(pattern.toLowerCase())) {
                        ret.add(s);
                      }
                    }
                    return ret;
                  },
                  itemBuilder: (context, suggestion) {
                    return SingleChildScrollView(
                      child: ListTile(
                        title: Text(suggestion),
                      ),
                    );
                  },
                  onSuggestionSelected: (selected) {
                    if (values.contains(selected.toLowerCase()) ||
                        selected.contains("All Links")) {
                      Fluttertoast.showToast(
                        msg: "Already chose that crate!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      setState(() {
                        values.add(selected.toLowerCase());
                      });
                      crateController.clear();
                    }
                  },
                  suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                    constraints: BoxConstraints(maxHeight: 250),
                    hasScrollbar: true,
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  String res = crateController.value.text;
                  if (values.contains(res.toLowerCase()) ||
                      res.contains("All Links")) {
                    Fluttertoast.showToast(
                      msg: "Already chose that crate!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    setState(() {
                      values.add(res.toLowerCase());
                    });
                    crateController.clear();
                  }
                },
                icon: const Icon(LineIcons.check))
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(values.length, (int index) {
              return Chip(
                label: Text(values[index]),
                onDeleted: () {
                  setState(() {
                    values.removeAt(index);
                  });
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}



// Future<List<CrateOptions>> getCrates(String query) async {
//   MyDatabaseHelper databaseHelper = MyDatabaseHelper();
//   var queryAllRows = await databaseHelper.queryAllRows("table_list");
//   List<CrateOptions> result = [];
//   for(Map<String, dynamic> table in queryAllRows) {
//     if(table['name'] != "All Links") {
//       result.add(CrateOptions(table['name']));
//     }
//   }
//   return result.where((lang) => lang.name.toLowerCase().contains(query.toLowerCase())).toList();
// }

class PersistentAppBar extends StatelessWidget with PreferredSizeWidget {
  const PersistentAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Opacity(
        //Wrap your `AppBar`
        opacity: 0.9,
        child: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("ArtCrates"),
          centerTitle: true,
          bottomOpacity: 0.5,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(LineIcons.bars),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
    );
  }
}
