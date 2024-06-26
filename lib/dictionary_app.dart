import 'dart:async';

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
  final Map<String, String> diacriticsMap = {
    'ā': 'a',
    'ī': 'i',
    'ū': 'u',
    'ṅ': 'n',
    'ñ': 'n',
    'ṃ': 'm',
    'ṭ': 't',
    'ḍ': 'd',
    'ṇ': 'n',
    'ḷ': 'l',
  };
  final Map<String, String> equivalences = {
    'a': 'aā',
    'i': 'iī',
    'u': 'uū',
    'n': 'nṅñṇ',
    'm': 'mṃ',
    't': 'tṭ',
    'd': 'dḍ',
    'l': 'lḷ',
  };

  @override
  void initState() {
    super.initState();
    // Load dictionary data when the app starts
    loadDictionaryData();
    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        currentSearchQuery = _searchController.text;
        searchResults = searchDictionary(currentSearchQuery.trim());
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

  List<String> _generateCombinations(String query) {
    final Map<int, List<String>> combinationsMap = {
      0: [query]
    };
    final Set<String> visited = {
      query
    }; // Track visited combinations to avoid duplicates
    final List<String> chars = query.split('');
    for (final char in chars) {
      if (!equivalences.containsKey(char)) {
        continue; // Skip if the character has no equivalents
      }
      final String equiv = equivalences[char]!;
      final List<String> newCombinations = [];
      for (final entry in combinationsMap.entries) {
        final int index = entry.key;
        final List<String> combos = entry.value;
        for (final combo in combos) {
          final newCombo = combo.replaceRange(index, index + 1, equiv);
          if (!visited.contains(newCombo)) {
            newCombinations.add(newCombo);
            visited.add(newCombo);
          }
        }
      }
      combinationsMap.addAll(newCombinations
          .asMap()
          .map((index, combo) => MapEntry(index + 1, [combo])));
    }
    return combinationsMap.values
        .expand((combinations) => combinations)
        .toList();
  }

  List<Map<String, String>> searchDictionary(String query) {
    if (query.isEmpty) {
      return [];
    }

    final String processedQuery = removeDiacritics(query.toLowerCase());

    if (currentMode == TranslationMode.englishToPali) {
      // Filter matching entries from dictionary based on English word
      final List<Map<String, String>> allEntries =
          dictionaryData[currentMode] ?? [];
      final matchingEntries = allEntries.where((entry) {
        final String word =
            removeDiacritics(entry['word']?.toLowerCase() ?? '');
        return word.startsWith(processedQuery);
      }).toList();

      // Sort and return matching entries
      if (matchingEntries.isNotEmpty) {
        matchingEntries
            .sort((a, b) => a['word']!.length.compareTo(b['word']!.length));
      }
      return matchingEntries;
    }

    // Generate combinations and convert to lowercase
    final List<String> combinations = _generateCombinations(processedQuery);
    final Set<String> lowercasedQueries = Set.from(
        combinations.map((combo) => removeDiacritics(combo.toLowerCase())));

    // Filter matching entries from dictionary
    final List<Map<String, String>> allEntries =
        dictionaryData[currentMode] ?? [];
    final List<Map<String, String>> matchingEntries = [];
    for (final entry in allEntries) {
      final String word = removeDiacritics(entry['word']?.toLowerCase() ?? '');
      if (lowercasedQueries.any((query) => word.startsWith(query))) {
        matchingEntries.add(entry);
      }
    }

    // Sort and return matching entries
    if (matchingEntries.isNotEmpty &&
        currentMode != TranslationMode.paliToVNese) {
      matchingEntries
          .sort((a, b) => a['word']!.length.compareTo(b['word']!.length));
      return matchingEntries;
    }

    // If no results found and current mode is paliToVNese, perform additional search
    final List<Map<String, String>> additionalSearch =
        dictionaryData[TranslationMode.paliToVNese] ?? [];
    final List<Map<String, String>> additionalMatches = [];
    for (final entry in additionalSearch) {
      final String word = removeDiacritics(entry['word']?.toLowerCase() ?? '');
      if (lowercasedQueries.any((query) => word.startsWith(query))) {
        additionalMatches.add(entry);
      }
    }

    // Sort additional matching entries
    if (additionalMatches.isNotEmpty) {
      additionalMatches
          .sort((a, b) => a['word']!.length.compareTo(b['word']!.length));
    }

    return additionalMatches;
  }

  String removeDiacritics(String input) {
    return input.replaceAllMapped(
      RegExp('[${diacriticsMap.keys.join()}]'),
      (match) => diacriticsMap[match.group(0)]!,
    );
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
                              color: Colors.black87, fontSize: 16),
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
                          const TextStyle(color: Colors.black87, fontSize: 16),
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
                            _searchController.text = wordDetails['word'] ?? '';
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
