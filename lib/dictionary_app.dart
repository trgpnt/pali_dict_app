import 'package:dict_app/service_layer/dictionary_read_service.dart';
import 'package:dict_app/widget/word_details_widget.dart';
import 'package:flutter/material.dart';

import 'search_results.dart';

enum TranslationMode { englishToPali, paliToEnglish, paliToVNese }

class DictionaryApp extends StatefulWidget {
  const DictionaryApp({super.key});

  @override
  _DictionaryAppState createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  Map<TranslationMode, List<Map<String, String>>> dictionaryData = {};
  List<Map<String, String>> searchResults = [];
  TranslationMode currentMode = TranslationMode.paliToEnglish;
  Map<String, String> selectedWord = {};
  String currentSearchQuery = '';
  final DictionaryReadService _dictionaryReadService = DictionaryReadService();

  @override
  void initState() {
    super.initState();
    // Load dictionary data when the app starts
    loadDictionaryData();
  }

  Future<void> loadDictionaryData() async {
    try {
      Stopwatch stopwatch = Stopwatch()..start();
      dictionaryData[TranslationMode.englishToPali] =
          await _dictionaryReadService.loadDictionary(
              'assets/english-pali_Ven_A_P_Buddhadatta-2.4.2.txt');
      dictionaryData[TranslationMode.paliToEnglish] =
          await _dictionaryReadService.loadDictionary(
              'assets/pali-english_Ven_A_P_Buddhadatta-2.4.2.txt');
      dictionaryData[TranslationMode.paliToVNese] = await _dictionaryReadService
          .loadDictionary('assets/conbimed_pali_vnese.txt');
      print(
          'Finished loading in ${stopwatch.elapsed.inMilliseconds} miliseconds');
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

    // If result is empty and current mode is TranslationMode.paliToVNese, perform additional search
    if (result.isNotEmpty) {
      return result;
    }
    final List<Map<String, String>> additionalSearch =
        dictionaryData[TranslationMode.paliToVNese] ?? [];

    // Apply the same search logic to the additional data
    final List<Map<String, String>> additionalMatches = additionalSearch
        .where((entry) =>
            entry['word']?.toLowerCase() == lowercasedQuery ||
            entry['meaning']?.toLowerCase() == lowercasedQuery ||
            entry['word']?.toLowerCase().contains(lowercasedQuery) == true ||
            entry['meaning']?.toLowerCase().contains(lowercasedQuery) == true)
        .toList();

    // Add the additional matches to the result
    result.addAll(additionalMatches);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  DropdownButtonFormField<TranslationMode>(
                    value: currentMode,
                    onChanged: (mode) {
                      setState(() {
                        currentMode = mode!;
                        currentSearchQuery = '';
                        searchResults = [];
                        selectedWord = {};
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Translation Direction',
                      labelStyle: const TextStyle(
                          color: Color(0xFF00838F),
                          decorationThickness: 10.0,
                          fontSize: 25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    items: TranslationMode.values
                        .where((mode) =>
                            mode !=
                            TranslationMode.paliToVNese) // Skip paliToVNese
                        .map((mode) {
                      return DropdownMenuItem<TranslationMode>(
                        value: mode,
                        child: Text(
                          mode == TranslationMode.paliToEnglish
                              ? 'Pali to English / Vietnamese'
                              : 'English to Pali',
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 20),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Add some space between the dropdown and text field
                  /**
                   * Search input field
                   */
                  TextField(
                    onChanged: (query) {
                      setState(() {
                        searchResults = searchDictionary(query);
                        currentSearchQuery = query;
                        selectedWord = {};
                      });
                    },
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: currentMode == TranslationMode.englishToPali
                          ? 'Enter English word'
                          : 'Enter Pali word',
                      hintStyle:
                          const TextStyle(color: Colors.black87, fontSize: 20),
                      suffixIcon: currentSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  currentSearchQuery = '\\';
                                  searchResults = [];
                                  selectedWord = {};
                                });
                              },
                            )
                          : const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    if (selectedWord.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: WordDetailsWidget(
                          word: selectedWord['word'] ?? '',
                          meaning: selectedWord['meaning'] ?? '',
                          onClose: () {
                            setState(() {
                              selectedWord = {};
                              currentSearchQuery = '';
                            });
                          },
                        ),
                      ),
                    if (searchResults.isNotEmpty)
                      Expanded(
                        child: SearchResults(
                          searchResults: searchResults,
                          onTap: (wordDetails) {
                            setState(() {
                              selectedWord = wordDetails;
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
