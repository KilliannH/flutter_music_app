import 'package:flutter/material.dart';

import './question.dart';
import './answer.dart';

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
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  var _questionIndex = 0;

  void _answerQuestion() {
    setState(() {
      _questionIndex += 1;
    });
    print('Answer chosen !');
  }

  @override
  Widget build(BuildContext context) { // build method always responsible to return a new Widget.

    // data
    var questions = [
      'What\'s your favorite color?',
      'What\'s your favorite animals?',
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My Music'),
        ),
        body: Column(
          children: [
            Question(
                questions[_questionIndex]
            ),
            Answer('Answer 1', _answerQuestion),
            Answer('Answer 2', _answerQuestion),
            Answer('Answer 3', _answerQuestion),
            Answer('Answer 4', _answerQuestion),
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
