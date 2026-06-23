// dart:io provides file system access, stdin, stdout, and more.
import 'dart:io';
// dart:convert provides tools for encoding and decoding data formats like JSON.
// NEW in Phase 2: This is how we turn the raw JSON string from Wikipedia into a usable Dart object.
import 'dart:convert';
// The http package handles our network requests, aliased as http to avoid naming conflicts.
import 'package:http/http.dart' as http;

const version = '0.0.2'; // Bumped to reflect our Phase 2 additions.

// ===========================================================================
// NEW in Phase 2: WikiArticle — A Dart class to model the Wikipedia response.
// ===========================================================================
// Instead of passing raw JSON strings around, we parse the API response once
// and store it in a structured object. This makes the rest of our code cleaner
// because we work with article.title instead of json['title'] everywhere.
//
// Learn: Dart classes, named parameters, required vs optional, factory constructors,
//        getters, and the null-aware operators ?? and ?. for safe JSON parsing.
class WikiArticle {
  // `final` fields: set once in the constructor, never changed after that.
  final String title;
  final String description;
  final String extract; // The full plain-text summary from Wikipedia.
  final String url;

  // A const constructor means this class can produce compile-time constants
  // if all its fields are also const. `required` enforces that callers must
  // supply every named parameter — no silent null defaults.
  const WikiArticle({
    required this.title,
    required this.description,
    required this.extract,
    required this.url,
  });

  // A factory constructor is a special constructor that can do work (like
  // parsing) before returning an instance. The `fromJson` naming pattern is
  // a Dart convention — you'll see it in almost every real-world Dart project.
  //
  // `Map<String, dynamic>` is Dart's type for a JSON object: keys are always
  // Strings, but values can be anything (String, int, List, another Map, etc.)
  factory WikiArticle.fromJson(Map<String, dynamic> json) {
    return WikiArticle(
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? 'No description available.',
      extract: json['extract'] ?? 'No content available.',
      // The ?. operator is null-aware chaining: if content_urls is null,
      // we stop immediately and return null instead of crashing.
      // The ?? at the end provides a fallback if the whole chain is null.
      url: json['content_urls']?['desktop']?['page'] ?? 'No URL available.',
    );
  }

  // A getter is a computed property — it looks like a field to callers, but
  // it runs logic. `briefSummary` extracts only the first sentence of the extract.
  String get briefSummary {
    // split('. ') divides the text at every '. ' (period + space).
    // .first grabs the first sentence. We add the period back since split removed it.
    final firstSentence = extract.split('. ').first;
    return '$firstSentence.';
  }
}

// ===========================================================================
// main: The entry point. Parses the top-level command and dispatches.
// ===========================================================================
void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {
    printUsage();
  } else if (arguments.first == 'version') {
    print('Dartpedia CLI version $version');
  } else if (arguments.first == 'wikipedia') {
    final remainingArgs = arguments.length > 1 ? arguments.sublist(1) : null;
    searchWikipedia(remainingArgs);
  } else if (arguments.first == 'search') {
    // NEW: 'search' finds article title suggestions, 'wikipedia' fetches a full article.
    // Example: dart bin/cli.dart search quantum physics
    final remainingArgs = arguments.length > 1 ? arguments.sublist(1) : null;
    searchSuggestions(remainingArgs);
  } else {
    printUsage();
  }
}

// ===========================================================================
// searchWikipedia: Updated to support --brief and --save flags.
// ===========================================================================
// NEW in Phase 2: We now scan arguments for flags (starting with '--') before
// treating the remaining words as the article title.
//
// Learn: for-in loops over a List, string methods like startsWith(),
//        and a simple manual approach to flag parsing.
void searchWikipedia(List<String>? arguments) async {
  // Flags that the user can optionally pass in:
  bool saveToFile = false; // --save: write the article to a .txt file on disk
  bool briefMode = false;  // --brief: show only the first sentence of the summary

  // titleParts collects every argument that isn't a flag.
  final List<String> titleParts = [];

  if (arguments != null) {
    for (final arg in arguments) {
      if (arg == '--save') {
        saveToFile = true;
      } else if (arg == '--brief') {
        briefMode = true;
      } else {
        // Anything that isn't a known flag is treated as part of the title.
        titleParts.add(arg);
      }
    }
  }

  // If no title was found in the arguments, prompt the user interactively.
  final String articleTitle;
  if (titleParts.isEmpty) {
    print('Please provide an article title.');
    final inputFromStdin = stdin.readLineSync();
    if (inputFromStdin == null || inputFromStdin.isEmpty) {
      print('No article title provided. Exiting.');
      return;
    }
    articleTitle = inputFromStdin;
  } else {
    articleTitle = titleParts.join(' ');
  }

  print('Looking up "$articleTitle" on Wikipedia. Please wait...');

  // getWikipediaArticle now returns WikiArticle? (nullable) — null means
  // the fetch failed, so we can handle that case cleanly.
  final article = await getWikipediaArticle(articleTitle);

  if (article == null) {
    print('Could not find an article for "$articleTitle". Try a different title or use the `search` command.');
    return;
  }

  // Display the article, respecting the --brief flag.
  printArticle(article, brief: briefMode);

  // If --save was passed, write the article to disk.
  if (saveToFile) {
    await saveArticleToFile(article);
  }
}

// ===========================================================================
// NEW in Phase 2: searchSuggestions — The 'search' command.
// ===========================================================================
// Wikipedia has a separate OpenSearch API that accepts a loose query and
// returns a list of matching article titles. This is useful when you're not
// sure of the exact title to pass to 'wikipedia'.
//
// Learn: async functions, early returns for error handling.
void searchSuggestions(List<String>? arguments) async {
  final String query;
  if (arguments == null || arguments.isEmpty) {
    print('Please provide a search query.');
    final inputFromStdin = stdin.readLineSync();
    if (inputFromStdin == null || inputFromStdin.isEmpty) {
      print('No query provided. Exiting.');
      return;
    }
    query = inputFromStdin;
  } else {
    query = arguments.join(' ');
  }

  print('Searching Wikipedia for "$query"...');

  final suggestions = await getSearchSuggestions(query);

  if (suggestions.isEmpty) {
    print('No results found for "$query".');
    return;
  }

  print('\n=== Search Results for "$query" ===');
  // `for (int i = 0; ...)` is an index-based loop — useful when you need
  // the position of each item, not just the item itself.
  for (int i = 0; i < suggestions.length; i++) {
    print('  ${i + 1}. ${suggestions[i]}');
  }
  print('\nTip: Use `dart bin/cli.dart wikipedia <ARTICLE-TITLE>` to fetch the full summary.');
}

// ===========================================================================
// printArticle: Formats and prints a WikiArticle to the console.
// ===========================================================================
// NEW in Phase 2: Replaces the raw `print(articleContent)` from Phase 1.
// Named parameters with a default value ({bool brief = false}) let callers
// omit the flag entirely, and it defaults to false.
void printArticle(WikiArticle article, {bool brief = false}) {
  print('\n=== ${article.title} ===');
  // Only print the description line if one actually exists (non-empty).
  if (article.description.isNotEmpty) {
    print('${article.description}\n');
  }
  // Ternary: if brief is true, show one sentence; otherwise show the full extract.
  print(brief ? article.briefSummary : article.extract);
  print('\nRead more: ${article.url}');
}

// ===========================================================================
// NEW in Phase 2: saveArticleToFile — Writes a WikiArticle to a .txt file.
// ===========================================================================
// Learn: `dart:io` File class, Future<void> for async functions with no return
//        value, and StringBuffer for efficiently building up a large string.
Future<void> saveArticleToFile(WikiArticle article) async {
  // Build a safe filename: replace spaces with underscores.
  // replaceAll() substitutes every occurrence of the first argument with the second.
  final filename = '${article.title.replaceAll(' ', '_')}.txt';
  final file = File(filename);

  // StringBuffer is more efficient than repeated string concatenation (+=)
  // because it avoids creating a new String object on every append.
  final buffer = StringBuffer();
  buffer.writeln('=== ${article.title} ===');
  buffer.writeln(article.description);
  buffer.writeln('');
  buffer.writeln(article.extract);
  buffer.writeln('');
  buffer.writeln('Source: ${article.url}');

  // writeAsString is async: it returns a Future<File> that resolves when
  // the write to disk is complete. We await it so we don't print "saved"
  // before the file is actually written.
  await file.writeAsString(buffer.toString());
  print('\nArticle saved to "$filename".');
}

// ===========================================================================
// printUsage: Updated to document all commands and flags.
// ===========================================================================
// NEW in Phase 2: Multi-line strings. A triple-quoted string (''' ... ''')
// spans multiple lines without needing \n everywhere. Much more readable for
// help text or templates.
void printUsage() {
  print('''
Dartpedia CLI — A Wikipedia lookup tool.

Commands:
  help                          Show this help message.
  version                       Show the CLI version.
  wikipedia <ARTICLE-TITLE>     Fetch a Wikipedia article summary.
    --brief                     Show only the first sentence of the summary.
    --save                      Save the full article to a .txt file.
  search <QUERY>                Search Wikipedia for matching article titles.

Examples:
  dart bin/cli.dart wikipedia Dart programming language
  dart bin/cli.dart wikipedia --brief Black hole
  dart bin/cli.dart wikipedia --save Eiffel Tower
  dart bin/cli.dart search quantum physics
  ''');
}

// ===========================================================================
// getWikipediaArticle: Updated to return WikiArticle? instead of String.
// ===========================================================================
// The return type changed from Future<String> to Future<WikiArticle?>.
// Returning null on failure (instead of an error string) is cleaner because
// the caller can use an `if (article == null)` check rather than checking
// whether a string starts with "Error:".
//
// Learn: jsonDecode() from dart:convert, casting dynamic to a specific type,
//        and how factory constructors bridge raw data and structured objects.
Future<WikiArticle?> getWikipediaArticle(String articleTitle) async {
  final url = Uri.https(
    'en.wikipedia.org',
    '/api/rest_v1/page/summary/$articleTitle',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // jsonDecode() parses a JSON string into a Dart object.
    // The result is `dynamic`, so we cast it to Map<String, dynamic>
    // to tell Dart (and ourselves) what shape to expect.
    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    // The factory constructor handles all the field extraction.
    return WikiArticle.fromJson(jsonData);
  }

  print('Error: Failed to fetch "$articleTitle". Status code: ${response.statusCode}');
  return null;
}

// ===========================================================================
// NEW in Phase 2: getSearchSuggestions — Calls the Wikipedia OpenSearch API.
// ===========================================================================
// This is a different Wikipedia endpoint from getWikipediaArticle. It accepts
// a loose search term and returns a JSON *array* (not an object), structured as:
//   [queryString, [titles], [descriptions], [urls]]
// So index 1 of the outer array gives us the list of matching article titles.
//
// Learn: Uri.https with query parameters (the 4th argument is a Map), parsing
//        a JSON array (List<dynamic>) instead of a JSON object (Map), and
//        List<String>.from() to safely convert List<dynamic> to List<String>.
Future<List<String>> getSearchSuggestions(String query) async {
  final url = Uri.https(
    'en.wikipedia.org',
    '/w/api.php',
    // Query parameters are passed as a Map<String, String>.
    // Uri.https automatically URL-encodes them (e.g., spaces become %20).
    {
      'action': 'opensearch',
      'search': query,
      'limit': '5',    // Return at most 5 suggestions.
      'format': 'json',
    },
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    // The response is a JSON array, so we decode it as List<dynamic>.
    final List<dynamic> jsonData = jsonDecode(response.body);
    // jsonData[1] is the second element — the list of article title strings.
    // List<String>.from() safely converts each dynamic element to a String.
    return List<String>.from(jsonData[1]);
  }

  // Return an empty list on failure — the caller checks `.isEmpty` to handle it.
  return [];
}

/*
=== PHASE 2 LEARNING SUMMARY ===

What's new and why it matters:

1. dart:convert + jsonDecode()
   Phase 1 printed raw JSON strings. Phase 2 parses them into Dart Maps and
   Lists using jsonDecode(). This is the standard way to consume any REST API.

2. Dart Classes + Factory Constructors
   WikiArticle wraps the parsed JSON into a typed object. The factory
   constructor (WikiArticle.fromJson) is a pattern you'll see in virtually
   every Dart/Flutter project that talks to an API.

3. Null-aware operators (??, ?.)
   json['content_urls']?['desktop']?['page'] ?? 'No URL'
   The ?. chains null checks safely. The ?? provides a fallback. Together they
   handle missing or incomplete API responses without crashing.

4. Getters
   `String get briefSummary` is computed on demand, like a method, but accessed
   like a field: article.briefSummary. Great for derived/formatted data.

5. Flag parsing (--brief, --save)
   Simple manual scanning of arguments with startsWith or equality checks.
   Real CLIs use the `args` package, but doing it manually first builds intuition.

6. dart:io File + StringBuffer
   File('name.txt').writeAsString(content) writes to disk asynchronously.
   StringBuffer is more efficient than string += for building large strings.

7. Different JSON shapes
   getWikipediaArticle returns a JSON object → Map<String, dynamic>
   getSearchSuggestions returns a JSON array → List<dynamic>
   Knowing which to expect (and how to decode each) is a core API skill.

8. Multi-line strings (''' ... ''')
   Triple quotes let you write readable multi-line text without \n everywhere.
   Widely used for help text, SQL queries, HTML templates, etc.
*/