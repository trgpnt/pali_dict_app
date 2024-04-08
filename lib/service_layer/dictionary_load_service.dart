// dictionary_load_service.dart
import 'dart:convert';

import 'package:flutter/services.dart' show ByteData, rootBundle;

class DictionaryLoadService {
  // Private constructor
  DictionaryLoadService._();

  // Singleton instance
  static final DictionaryLoadService _instance = DictionaryLoadService._();

  // Getter for the instance
  factory DictionaryLoadService() {
    return _instance;
  }

  Future<List<Map<String, String>>> loadDictionary(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final String content = utf8.decode(data.buffer.asUint8List());

      List<String> lines = LineSplitter.split(content).toList();
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
