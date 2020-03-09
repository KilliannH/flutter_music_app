import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/aPlayer.dart';
import 'package:flutter_music_app/playerScreen.dart';

import 'package:flutter_music_app/services/dataService.dart';
import 'package:flutter_music_app/songItem.dart';
import 'package:provider/provider.dart';

// By convention : first import block for all packages, second import for our own files.

void main() {
  runApp(MyApp());
}

// @Required : in a constructor w. name based arguments ({String name, int age = 31});
// required set the argument as required. Here if we don't specify an age, the default value is 31.
// we can avoid extra function body for the constructor ex :

/*
class Person
  String name,
  int age;

  Person({this.name, this.age = 30}); // named based constructor w. Dart assignation shortcut.
 */

// Dart knows that for every instantiated objects, it will pass the name & age property directly from the constructor
// new keyword for instances is not required.
//MyApp() is an instance of MyApp class, we need the parentheses so Dart will not consider it as an argument type.

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final List<String> appRoutes = const ['Albums', 'Artists', 'Add'];

  @override
  Widget build(BuildContext context) {
    // build method always responsible to return a new Widget.

    return MaterialApp(
          home: Builder(
            builder: (navContext) => Scaffold(
            appBar: this._buildAppBar(navContext),
              body: FutureBuilder<dynamic>(
                future: DataService.getSongs(),
                // a previously-obtained Future<dynamic> or null
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    List songs = snapshot.data;
                    return _buildSongList(songs, context);
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          )
                        ]));
                  } else {
                    return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(),
                            width: 60,
                            height: 60,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Awaiting result...'),
                          )
                        ]));
                  }
                },
              ),
            ),
          ),
    );
  }

  _buildAppBar(navContext) {
    return AppBar(title: Text('My Music'), actions: <Widget>[
      // overflow menu
      PopupMenuButton<Object>(
        onSelected: (value) {},
        itemBuilder: (BuildContext context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(PopupMenuItem<Object>(
            value: 1,
            child: Text('Add New'),
          ));
          return list;
        },
      ),
    ]);
  }

  _buildSongList(songs, context) {

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            child: Container(
              height: 70,
              child: SongItem(songs[index].title, songs[index].artist,
                  songs[index].albumImg),
            ),
            onTap: () {
              return Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(songs[index])));
            }
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

// The role of Scaffold is to create a base design for our app
// you compose your app by mixing widgets, and basically everything is a widget.

// / ! \ Always add a comma after your instantiated widget

// we can only pass 1 Widget to the body.

// 2 types of Widgets : Output, Input (Text, Card...) : VISIBLE, Layout, Control (Row, Columns...) : INVISIBLE

// Ctrl Q to see the function signature.

// All classes have to work as a Standalone.

// the callback for onPressed is executed (we don't pass the function with parentheses).

// Here we try to change the state of a widget in a stateless Widget...

// A Stateful widget is a combination of 2 classes

// Typically, a widget state class will be the name of the class + State and it will extend a state.

// The Widget that extends the Stateful Widget will override createSTate() that returns the WidgetClassState
// When a state has changed, we call setState() and we pass the changed value in this function.
// under the hood, the build method from the stateful widget is called again.

// In Dart, we can control what could be accessed from another file.
// _ mark make a class private and accessible only inside that file.

// Good convention rule = 1 Widget per file. (exception, ex if you have two widgets that really works together)

// You manage the state of child widgets (Question, Answer) in the parent widget (AppWidget)
// This pattern is called lifting state up

// We can pass the callback of buttonPressed in the Answer Widget

// an equivalent to the js object in Dart is a Map. we can instantiate a map with Map() or with curly braces {}, it stores data in key, value pairs.
// The key could be a string or an int, we typically use a string because it's more human readable so {'questionText' : 'myQuestion', 'answerText': 'myAnswer'}.

// map execute a function on every element of the list you want to map.

// the spread operator takes the current list (Column children array) and add the new list generated by the map function (aka an Answer Widget list).
// Don't forget to add .toList() at the end of the map function.

// final means : a runtime constant value. It will be lock as the first value initialized.
// const is never reassigned at compile time.
// for any object that we created, meaning every variables, dart assign an address to them.

// "It will not changed when it has its initialize value" => use final
// "It will never changed" => use const

// You can split widgets with subwidgets : in general it's always encouraged to create more small widgets
// better for readable code & performance.
