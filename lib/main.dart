import 'package:flutter/material.dart';

import 'dictionary_app.dart';
import 'loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const int waitingOnMilisec = 3000;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<void>(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const DictionaryHomePage(); // Transition to the main page
          } else {
            return const InitialLoadingScreen(); // Show the loading screen while initializing
          }
        },
      ),
    );
  }

  Future<void> init() async {
    // Perform your initialization tasks here
    // This could be loading data, setting up services, etc.
    await Future.delayed(
        const Duration(milliseconds: waitingOnMilisec)); // Simulating a delay
  }
}

class DictionaryHomePage extends StatefulWidget {
  const DictionaryHomePage({super.key});

  @override
  _DictionaryHomePageState createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  static const HOME_PAGE_TITLE = "PALI DICTIONARY";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.yellow.shade50),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade50, // Yellow shade
          title: Container(
            padding: const EdgeInsets.all(8.0), // Padding around the text
            decoration: BoxDecoration(
              color: const Color(0xFFFF963B),
              // Same color as AppBar background
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            child: const Text(
              HOME_PAGE_TITLE,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.yellow, // Text color
              ),
            ),
          ),
        ),
        body: const DictionaryApp(),
      ),
    );
  }
}
