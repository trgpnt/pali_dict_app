// dictionary_read_service.dart
import 'dart:convert';

import 'package:flutter/services.dart' show ByteData, rootBundle;

class DictionaryReadService {
  // Private constructor
  DictionaryReadService._();

  // Singleton instance
  static final DictionaryReadService _instance = DictionaryReadService._();

  // Getter for the instance
  factory DictionaryReadService() {
    return _instance;
  }

  Future<List<Map<String, String>>> loadDictionary(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final String content = utf8.decode(data.buffer.asUint8List());
      final List<String> lines = LineSplitter.split(content).toList();

      // Splitting lines into two halves
      final int halfLength = (lines.length / 2).ceil();
      final List<String> firstHalfLines = lines.sublist(0, halfLength);
      final List<String> secondHalfLines = lines.sublist(halfLength);

      // Processing first half of lines
      final Future<List<Map<String, String>>> firstHalfFuture =
          _processLines(firstHalfLines);

      // Processing second half of lines
      final Future<List<Map<String, String>>> secondHalfFuture =
          _processLines(secondHalfLines);

      // Waiting for both halves to finish and combining the results
      final List<List<Map<String, String>>> results =
          await Future.wait([firstHalfFuture, secondHalfFuture]);
      final List<Map<String, String>> combinedResults =
          results.expand((list) => list).toList();

      return combinedResults;
    } catch (e) {
      print('Error loading dictionary data: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> _processLines(List<String> lines) async {
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
    return entries;
  }
}
