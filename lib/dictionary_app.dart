import 'package:dict_app/service_layer/dictionary_load_service.dart';
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
  final DictionaryLoadService _dictionaryReadService = DictionaryLoadService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load dictionary data when the app starts
    loadDictionaryData();
    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        currentSearchQuery = _searchController.text;
        searchResults = searchDictionary(currentSearchQuery);
        selectedWord = {};
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadDictionaryData() async {
    try {
      Stopwatch stopwatch = Stopwatch()..start();

      List<Future<List<Map<String, String>>>> loadingFutures = [
        _dictionaryReadService.loadDictionary(
            'assets/english-pali_Ven_A_P_Buddhadatta-2.4.2.txt'),
        _dictionaryReadService.loadDictionary(
            'assets/pali-english_Ven_A_P_Buddhadatta-2.4.2.txt'),
        _dictionaryReadService.loadDictionary('assets/conbimed_pali_vnese.txt'),
      ];

      List<List<Map<String, String>>> results =
          await Future.wait(loadingFutures);

      // Assigning loaded dictionaries to dictionaryData
      dictionaryData[TranslationMode.englishToPali] = results[0];
      dictionaryData[TranslationMode.paliToEnglish] = results[1];
      dictionaryData[TranslationMode.paliToVNese] = results[2];

      print(
          'Finished loading in ${stopwatch.elapsed.inMilliseconds} milliseconds');
    } catch (e) {
      print('Error loading dictionary data: $e');
    }
  }

  List<Map<String, String>> searchDictionary(String query) {
    final lowercasedQuery = query.toLowerCase();
    final List<Map<String, String>> allEntries =
        dictionaryData[currentMode] ?? [];

    List<Map<String, String>> matchingEntries = allEntries
        .where((entry) =>
            entry['word']?.toLowerCase().startsWith(lowercasedQuery) == true)
        .toList();

    if (matchingEntries.isNotEmpty &&
        currentMode != TranslationMode.paliToVNese) {
      return matchingEntries;
    }

    // If no results found and current mode is paliToVNese, perform additional search
    final List<Map<String, String>> additionalSearch =
        dictionaryData[TranslationMode.paliToVNese] ?? [];

    List<Map<String, String>> additionalMatches = additionalSearch
        .where((entry) =>
            entry['word']?.toLowerCase().startsWith(lowercasedQuery) == true)
        .toList();

    return additionalMatches;
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
                        _searchController.clear();
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
                    controller: _searchController,
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
                                  _searchController.clear();
                                  currentSearchQuery = '';
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
                              _searchController.clear();
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
                              _searchController.clear();
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
