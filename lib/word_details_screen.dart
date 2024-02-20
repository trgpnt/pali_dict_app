// word_details_screen.dart

import 'package:flutter/material.dart';

class WordDetailsScreen extends StatefulWidget {
  final Map<String, String> wordDetails;

  //TODO eval if needed?
  final String searchQuery;

  const WordDetailsScreen({
    Key? key,
    required this.wordDetails,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _WordDetailsScreenState createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final String word = widget.wordDetails['word'] ?? '';
    final String meaning = widget.wordDetails['meaning'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Word Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container for the search query with light green background
            Container(
              color: Colors.lightGreen,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${word}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Container for the meaning with yellow background
            Container(
              color: Colors.yellow,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Meaning: $meaning',
                  style: const TextStyle(
                      color: Colors.black), // You can adjust the text color
                ),
              ),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
