# Book Finder

A single-screen Flutter app that searches the public Open Library catalog by
book title. Results show the title, author names, first publication year, and
a cover if one is available. The app calls Open Library directly over HTTPS.
It needs an internet connection and uses no API key, account, or database.

## Run in VS Code

1. Extract the ZIP and open the **book_finder** folder in VS Code. It contains
   `pubspec.yaml`.
2. Install the [Flutter SDK](https://docs.flutter.dev/install) and the Flutter
   extension for VS Code if needed. This project was built with Flutter 3.50.
   Run `flutter doctor` to check your setup.
3. Open a terminal in the project folder and run:

   ```sh
   flutter pub get
   flutter run -d chrome
   ```

   For Android, start an Android emulator or connect a phone with USB debugging.
   Use `flutter devices` to find its ID, then run
   `flutter run -d <device-id>` with that ID. The Android manifest already
   declares internet access.

## Where the code lives

| File | What it does |
| --- | --- |
| `lib/main.dart` | Builds the search screen and result cards. Stores the current request and uses `FutureBuilder` to render each state. |
| `lib/book_api.dart` | Builds the search URL, sends an HTTP GET, checks the status code, and converts the response's `docs` array into a list of books. |
| `lib/book.dart` | Maps the title, authors, year, and cover ID from a JSON object into a `Book`. |
| `pubspec.yaml` | Declares Flutter and the `http` package. |

Each submitted search requests up to 20 results and only the four fields shown
by the UI. The list builds rows as needed. The app fetches data when you press
Search or submit from the keyboard. A failed request shows a Retry button, and
an empty response shows a separate message.

## Viva demo

1. Open the app and search for **The Hobbit**. Point out the title, author, year,
   and cover in the results.
2. Search for **Feluda** to show that the results change with the title.
3. Search for **zzzxqvnoresults987** to demonstrate the empty state.
4. If asked about errors, turn off internet access, search for a new title,
   then reconnect and tap **Retry**.

### What to say

> আমার project-এর নাম Book Finder। User একটা book title লিখে Search দিলে
> Flutter app Open Library Search API-তে একটা HTTP GET request পাঠায়।
> Response-এর JSON থেকে `docs` list পাই। প্রতিটা item-কে `Book.fromJson`
> দিয়ে `Book` object বানাই। `FutureBuilder` request চলার সময় loading
> দেখায়, আর result আসলে title, author, publication year আর cover দেখায়।
> Search fail করলে user Retry করতে পারে।

### Quick viva questions

- **Why use `FutureBuilder`?** An HTTP response arrives asynchronously.
  `FutureBuilder` updates the screen as the current request completes.
- **What does `setState` do here?** It tells Flutter to rebuild the screen with
  the new search request after the user submits a title.
- **Why use `Uri.https`?** It builds the HTTPS URL and safely encodes titles
  with spaces, punctuation, or Bangla characters.
- **What if an author, year, or cover is missing?** The card shows an unknown
  author or year label, or a book icon in place of the cover.
- **Where does the data come from?** Open Library sends catalog records as JSON.
  Cover images load from its Covers API using each result's cover ID.

[Open Library Search API](https://openlibrary.org/dev/docs/api/search) ·
[Open Library Covers API](https://openlibrary.org/dev/docs/api/covers)
