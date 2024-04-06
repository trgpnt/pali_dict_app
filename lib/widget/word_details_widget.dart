import 'package:flutter/material.dart';

class WordDetailsWidget extends StatelessWidget {
  final String word;
  final String meaning;
  final VoidCallback onClose;

  const WordDetailsWidget({
    super.key,
    required this.word,
    required this.meaning,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.lightGreen,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  '$word',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
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
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
