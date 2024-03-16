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
      home: FutureBuilder<void>(
        // Simulate some asynchronous initialization
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyHomePage(); // Transition to the main page
          } else {
            return const LoadingScreen(); // Show the loading screen while initializing
          }
        },
      ),
    );
  }

  Future<void> init() async {
    // Perform your initialization tasks here
    // This could be loading data, setting up services, etc.
    await Future.delayed(const Duration(seconds: 1)); // Simulating a delay
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade200, // Yellow shade
          title: Container(
            padding: const EdgeInsets.all(8.0), // Padding around the text
            decoration: BoxDecoration(
              color: const Color(0xFFFF963B),
              // Same color as AppBar background
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            child: const Text(
              'Pali Dictionary',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.brown, // Text color
              ),
            ),
          ),
        ),
        body: DictionaryApp(),
      ),
    );
  }
}
