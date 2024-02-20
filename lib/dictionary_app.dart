import 'dart:convert';

import 'package:dict_app/word_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'search_results.dart';

enum TranslationMode { englishToPali, paliToEnglish }

class DictionaryApp extends StatefulWidget {
  @override
  _DictionaryAppState createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  Map<TranslationMode, List<Map<String, String>>> dictionaryData = {};
  List<Map<String, String>> searchResults = [];
  TranslationMode currentMode = TranslationMode.paliToEnglish;
  Map<String, String> selectedWord = {};
  String currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load dictionary data when the app starts
    loadDictionaryData();
  }

  Future<void> loadDictionaryData() async {
    try {
      await loadDictionary(
        'assets/english-pali_Ven_A_P_Buddhadatta-2.4.2.txt',
        TranslationMode.englishToPali,
      );
      await loadDictionary(
        'assets/pali-english_Ven_A_P_Buddhadatta-2.4.2.txt',
        TranslationMode.paliToEnglish,
      );
    } catch (e) {
      print('Error loading dictionary data: $e');
    }
  }

  Future<void> loadDictionary(String assetPath, TranslationMode mode) async {
    try {
      final String data = await rootBundle.loadString(assetPath);

      List<String> lines = LineSplitter.split(data).toList();
      List<Map<String, String>> entries = [];

      String currentEntry = '';
      for (String line in lines) {
        if (line.contains('\t')) {
          final List<String> parts = line.split('\t');
          if (parts.length == 2) {
            entries.add({'word': parts[0], 'meaning': parts[1]});
          }
        } else if (line.trim() == '.') {
          if (currentEntry.isNotEmpty) {
            final List<String> parts = currentEntry.split('\t');
            if (parts.length == 2) {
              entries.add({'word': parts[0], 'meaning': parts[1]});
            }
          }
          currentEntry = '';
        } else {
          currentEntry += line;
        }
      }

      dictionaryData[mode] = entries;
    } catch (e) {
      print('Error loading dictionary data: $e');
    }
  }

  List<Map<String, String>> searchDictionary(String query) {
    final lowercasedQuery = query.toLowerCase();
    final List<Map<String, String>> allEntries =
        dictionaryData[currentMode] ?? [];

    // Find exact matches
    final List<Map<String, String>> exactMatches = allEntries
        .where((entry) =>
            entry['word']?.toLowerCase() == lowercasedQuery ||
            entry['meaning']?.toLowerCase() == lowercasedQuery)
        .toList();

    // Find close matches (entries that contain the query)
    final List<Map<String, String>> closeMatches = allEntries
        .where((entry) =>
            entry['word']?.toLowerCase().contains(lowercasedQuery) == true ||
            entry['meaning']?.toLowerCase().contains(lowercasedQuery) == true)
        .toList();

    // Combine exact and close matches, placing exact matches first
    final List<Map<String, String>> result = [...exactMatches, ...closeMatches];

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pali Dictionary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<TranslationMode>(
              value: currentMode,
              onChanged: (mode) {
                setState(() {
                  currentMode = mode!;
                });
              },
              items: TranslationMode.values
                  .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode == TranslationMode.paliToEnglish
                            ? 'Pali to English'
                            : 'English to Pali'),
                      ))
                  .toList(),
            ),
            TextField(
              onChanged: (query) {
                setState(() {
                  // Update search results when the user types
                  searchResults = searchDictionary(query);
                  currentSearchQuery = query;
                });
              },
              decoration: InputDecoration(
                labelText: currentMode == TranslationMode.englishToPali
                    ? 'Search English Word'
                    : 'Search Pali Word',
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SearchResults(
                searchResults: searchResults,
                // Pass a callback to handle tap events
                onTap: (wordDetails) {
                  // Navigate to the details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordDetailsScreen(
                        wordDetails: wordDetails,
                        searchQuery: currentSearchQuery,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
