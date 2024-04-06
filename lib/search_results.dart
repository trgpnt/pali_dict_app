import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  final List<Map<String, String>> searchResults;
  final void Function(Map<String, String>) onTap;

  const SearchResults({
    super.key,
    required this.searchResults,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text('No results'),
      );
    }

    return ListView.separated(
      itemCount: searchResults.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(); // Use your own separator widget if needed
      },
      itemBuilder: (context, index) {
        return _buildListItem(context, searchResults[index]);
      },
    );
  }

  Widget _buildListItem(BuildContext context, Map<String, String> result) {
    return ListTile(
      title: Text(
        result['word'] ?? '',
        style: const TextStyle(fontSize: 17),
      ),
      onTap: () {
        onTap(result);
      },
    );
  }
}
