import 'package:flutter/material.dart';

import 'dictionary_app.dart';
import 'loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pali Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<void>(
        // Simulate some asynchronous initialization
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MyHomePage(); // Transition to the main page
          } else {
            return LoadingScreen(); // Show the loading screen while initializing
          }
        },
      ),
    );
  }

  Future<void> init() async {
    // Perform your initialization tasks here
    // This could be loading data, setting up services, etc.
    await Future.delayed(const Duration(seconds: 2)); // Simulating a delay
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Your existing code for the dictionary app here...

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pali Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DictionaryApp(),
    );
  }
}
