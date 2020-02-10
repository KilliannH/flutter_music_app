import 'package:flutter/material.dart';

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) { // build method always responsible to return a new Widget.

    // data
    var questions = [
      'What\'s your favorite color?',
      'What\'s your faforite animals?',
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My Music'),
        ),
        body: Column(
          children: [
            Text('The question'),
            RaisedButton(child: Text('Answer 1'), onPressed: null),
            RaisedButton(child: Text('Answer 2'), onPressed: null),
            RaisedButton(child: Text('Answer 3'), onPressed: null)
          ],
        ),
      ),
    );
  }
}

// Scaffold has a rol to create a base design for our app
// you compose your app by mixing widgets, and basically everithing is a widget.

// / ! \ Always add a comma after your instantiated widget

// we can only pass 1 Widget to the body.

// 2 types of Widgets : Output, Input (Text, Card...) : VISIBLE, Layout, Control (Row, Columns...) : INVISIBLE