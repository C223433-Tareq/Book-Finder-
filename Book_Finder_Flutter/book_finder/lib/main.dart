// Keep the SDK Material widgets for compatibility with earlier Flutter versions.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'book.dart';
import 'book_api.dart';

void main() => runApp(const BookFinderApp());

class BookFinderApp extends StatelessWidget {
  const BookFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF275A47)),
        scaffoldBackgroundColor: const Color(0xFFF5F5EE),
        useMaterial3: true,
      ),
      home: const BookSearchPage(),
    );
  }
}

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final _controller = TextEditingController();
  final _api = BookApi();
  Future<List<Book>>? _results;
  String _searchedTitle = '';

  void _search(String input) {
    final title = input.trim();
    if (title.isEmpty) return;

    FocusScope.of(context).unfocus();
    final request = _api.searchByTitle(title);
    // FutureBuilder displays errors after the next frame subscribes to the request.
    request.ignore();
    setState(() {
      _searchedTitle = title;
      _results = request;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Book Finder',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Search the Open Library catalog by title.'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _search,
                          decoration: const InputDecoration(
                            labelText: 'Book title',
                            hintText: 'e.g. The Hobbit',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _search(_controller.text),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<Book>>(
                      future: _results,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.none) {
                          return const Center(
                            child: Text('Enter a book title to get started.'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              semanticsLabel: 'Searching for books',
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Could not load books. Check your connection and try again.',
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: () => _search(_searchedTitle),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final books = snapshot.data!;
                        if (books.isEmpty) {
                          return Center(
                            child: Text(
                              'No books found for “$_searchedTitle”.',
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return ListView.separated(
                          key: ValueKey(_searchedTitle),
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: books.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 6),
                          itemBuilder:
                              (context, index) => _BookTile(book: books[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final year = book.firstPublished;
    final coverId = book.coverId;
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: const Icon(Icons.menu_book_outlined),
    );

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 44,
            height: 56,
            child:
                coverId == null
                    ? placeholder
                    : Image.network(
                      'https://covers.openlibrary.org/b/id/$coverId-M.jpg?default=false',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => placeholder,
                    ),
          ),
        ),
        title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${book.authors}\n${year == null ? 'Publication year unknown' : 'First published $year'}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
      ),
    );
  }
}
