import 'dart:convert';

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
    return Container(
      color: Colors.yellow,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pali Dictionary'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 16.0,
                  ),
                  DropdownButtonFormField<TranslationMode>(
                    value: currentMode,
                    onChanged: (mode) {
                      setState(() {
                        currentMode = mode!;
                      });
                    },
                    items: TranslationMode.values.map((mode) {
                      return DropdownMenuItem<TranslationMode>(
                        value: mode,
                        child: Text(
                          mode == TranslationMode.paliToEnglish
                              ? 'Pali to English'
                              : 'English to Pali',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Translation Mode',
                      labelStyle: TextStyle(color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    onChanged: (query) {
                      setState(() {
                        searchResults = searchDictionary(query);
                        currentSearchQuery = query;
                        selectedWord = {};
                      });
                    },
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: currentMode == TranslationMode.englishToPali
                          ? 'Search English Word'
                          : 'Search Pali Word',
                      hintStyle: TextStyle(
                        color: Colors.black87,
                      ),
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    if (selectedWord.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: WordDetailsWidget(
                          word: selectedWord['word'] ?? '',
                          meaning: selectedWord['meaning'] ?? '',
                        ),
                      ),
                    if (searchResults.isNotEmpty)
                      Expanded(
                        child: SearchResults(
                          searchResults: searchResults,
                          onTap: (wordDetails) {
                            setState(() {
                              selectedWord = wordDetails as Map<String, String>;
                              searchResults = [];
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WordDetailsWidget extends StatelessWidget {
  final String word;
  final String meaning;

  const WordDetailsWidget({Key? key, required this.word, required this.meaning})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.lightGreen,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              '$word',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: Colors.yellow,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              'Meaning: $meaning',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
