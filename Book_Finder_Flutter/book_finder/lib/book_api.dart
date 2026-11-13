import 'dart:convert';

import 'package:http/http.dart' as http;

import 'book.dart';

class BookApi {
  Future<List<Book>> searchByTitle(String title) async {
    // Uri.https encodes spaces, punctuation and non-Latin characters.
    final url = Uri.https('openlibrary.org', '/search.json', {
      'title': title,
      'fields': 'title,author_name,first_publish_year,cover_i',
      'limit': '20',
    });

    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Open Library returned HTTP ${response.statusCode}');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    final results = json['docs'] as List<dynamic>;
    return results
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
