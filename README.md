# dart-final-project

Final Project for CS420 course BYUH that teach by Bro. Slade. Purpose to learn dart as programming language.

## Lok Yiu Chan (Momo)

### Phase 1 - Dart Official Docs Tutorial

For Phase 1, I followed the official Dart tutorials from its Documentation (On their official website) Dart Official Tutorial. I completed 1-3. That includes: (I did it in bin/cli1.dart)

1. Build Your First App
2. Add Interactivity to Your App
3. Write Asynchronous Code

---

### Phase 2 - Add Features (AI Allowed)

Building on the base CLI from Phase 1, I extended **Dartpedia** with new commands, flag parsing, JSON parsing, and file I/O. The goal was to make the program genuinely useful — instead of dumping raw JSON at the user, it now formats output, supports search, and can save articles to disk. (I did it in bin/cli.dart)

What I added:

1. JSON Parsing with `dart:convert`
2. The `WikiArticle` Class
3. Flag Parsing — `--brief` and `--save`
4. Saving Articles to a File with `dart:io`
5. New `search` Command
6. Multi-line Strings for `printUsage()`

---

#### 1. JSON Parsing with `dart:convert`

Phase 1 printed the raw JSON string from Wikipedia directly to the terminal. Phase 2 parses it into a real Dart object using `jsonDecode()` from `dart:convert`.

```dart
import 'dart:convert';

final Map<String, dynamic> jsonData = jsonDecode(response.body);
```

**What I learned:** `jsonDecode()` converts a JSON string into a Dart `Map<String, dynamic>` (for JSON objects) or `List<dynamic>` (for JSON arrays). The `dynamic` type means the values can be anything — a String, int, another Map, a List — which reflects the flexible nature of JSON.

---

#### 2. The `WikiArticle` Class

Instead of passing raw Maps around the program, I created a class to model a Wikipedia article. This is a pattern called a **data class** — its only job is to hold structured data.

```dart
class WikiArticle {
  final String title;
  final String description;
  final String extract;
  final String url;

  const WikiArticle({ required this.title, ... });

  factory WikiArticle.fromJson(Map<String, dynamic> json) {
    return WikiArticle(
      title: json['title'] ?? 'Unknown Title',
      url: json['content_urls']?['desktop']?['page'] ?? 'No URL available.',
      ...
    );
  }
}
```

**What I learned:**

- **`factory` constructor** — a special constructor that can run logic (like parsing) before returning an instance. The `fromJson` naming convention is standard in Dart/Flutter for this pattern.
- **`??` (null-coalescing operator)** — if the left side is `null`, use the right side as a fallback. Essential for safely reading JSON fields that might be missing.
- **`?.` (null-aware access)** — chains field access safely. `json['content_urls']?['desktop']?['page']` stops and returns `null` instead of crashing if any step along the way is `null`.
- **Getters** — a getter looks like a field but computes its value on demand. I used one for `briefSummary`, which extracts just the first sentence of the article:

```dart
String get briefSummary {
  final firstSentence = extract.split('. ').first;
  return '$firstSentence.';
}
```

---

#### 3. Flag Parsing — `--brief` and `--save`

The `wikipedia` command now supports two optional flags:

| Flag      | Effect                                       |
| --------- | -------------------------------------------- |
| `--brief` | Shows only the first sentence of the summary |
| `--save`  | Saves the full article to a `.txt` file      |

```bash
dart bin/cli.dart wikipedia --brief Black hole
dart bin/cli.dart wikipedia --save Eiffel Tower
dart bin/cli.dart wikipedia --brief --save Dart programming language
```

I parse these by scanning the argument list before building the article title:

```dart
for (final arg in arguments) {
  if (arg == '--save') {
    saveToFile = true;
  } else if (arg == '--brief') {
    briefMode = true;
  } else {
    titleParts.add(arg); // Everything else is part of the title.
  }
}
```

**What I learned:** `for (final arg in arguments)` is Dart's for-in loop. It iterates over every element in a `List` without needing an index counter. I used `final` for `arg` because each loop variable is only read, never reassigned.

---

#### 4. Saving Articles to a File with `dart:io`

Phase 1 already imported `dart:io` for `stdin`, but Phase 2 uses the `File` class to write output to disk:

```dart
Future<void> saveArticleToFile(WikiArticle article) async {
  final filename = '${article.title.replaceAll(' ', '_')}.txt';
  final file = File(filename);

  final buffer = StringBuffer();
  buffer.writeln(article.title);
  buffer.writeln(article.extract);

  await file.writeAsString(buffer.toString());
  print('Article saved to "$filename".');
}
```

**What I learned:**

- **`File(path).writeAsString(content)`** — writes a string to a file asynchronously. It returns `Future<File>`, so we `await` it to make sure the write is complete before continuing.
- **`Future<void>`** — the return type for an async function that does work but doesn't return a value.
- **`StringBuffer`** — more efficient than building a long string with `+=`. Instead of creating a new `String` object on every append, `StringBuffer` accumulates everything in memory and converts once at the end with `.toString()`.
- **`replaceAll(' ', '_')`** — a `String` method that substitutes every occurrence of the first argument with the second. Used here to make the article title safe as a filename.

---

#### 5. New `search` Command

The new `search` command calls Wikipedia's **OpenSearch API** — a different endpoint from Phase 1 that accepts a loose query and returns up to 5 matching article titles.

```bash
dart bin/cli.dart search quantum physics
```

```
=== Search Results for "quantum physics" ===
  1. Quantum mechanics
  2. Physics
  3. Quantum field theory
  4. Introduction to quantum mechanics
  5. Quantum
```

This was the most interesting part of Phase 2 because the OpenSearch response is structured as a **JSON array**, not a JSON object:

```
[queryString, [titles], [descriptions], [urls]]
```

So the decoding is different from the article endpoint:

```dart
final List<dynamic> jsonData = jsonDecode(response.body);
final titles = List<String>.from(jsonData[1]); // Index 1 = the titles array
```

**What I learned:**

- `jsonDecode()` can return either a `Map` or a `List` depending on the JSON structure. You have to know which to expect from the API.
- `List<String>.from(dynamicList)` safely converts a `List<dynamic>` (what `jsonDecode` gives you) into a typed `List<String>`.
- `Uri.https()` accepts query parameters as a `Map<String, String>`. The `Uri` class URL-encodes them automatically, so spaces in the search query are handled correctly.

```dart
final url = Uri.https(
  'en.wikipedia.org',
  '/w/api.php',
  {
    'action': 'opensearch',
    'search': query,
    'limit': '5',
    'format': 'json',
  },
);
```

---

#### 6. Multi-line Strings for `printUsage()`

The help output became detailed enough that I switched to a triple-quoted string (`''' ... '''`), which spans multiple lines without needing `\n` everywhere:

```dart
void printUsage() {
  print('''
Dartpedia CLI — A Wikipedia lookup tool.

Commands:
  help                          Show this help message.
  wikipedia <ARTICLE-TITLE>     Fetch a Wikipedia article summary.
    --brief                     Show only the first sentence.
    --save                      Save the article to a .txt file.
  search <QUERY>                Search for article title suggestions.
  ''');
}
```

**What I learned:** Triple-quoted strings (`''' ... '''`) span multiple lines without needing `\n` everywhere. Useful for help text, templates, or any output where layout matters.

---

#### Full Command Reference

```bash
# Get a Wikipedia article summary (pretty-printed)
dart bin/cli.dart wikipedia <ARTICLE-TITLE>

# Get just the first sentence
dart bin/cli.dart wikipedia --brief <ARTICLE-TITLE>

# Save the full article to a .txt file
dart bin/cli.dart wikipedia --save <ARTICLE-TITLE>

# Combine flags
dart bin/cli.dart wikipedia --brief --save <ARTICLE-TITLE>

# Search for article title suggestions
dart bin/cli.dart search <QUERY>
```

---

#### Key Dart Concepts Introduced in Phase 2

| Concept                            | Where It's Used                            |
| ---------------------------------- | ------------------------------------------ |
| `dart:convert` / `jsonDecode()`    | Parsing Wikipedia API responses            |
| Classes + `factory` constructors   | `WikiArticle.fromJson()`                   |
| `??` and `?.` null-aware operators | Safe JSON field access                     |
| Getters                            | `WikiArticle.briefSummary`                 |
| `for (final x in list)`            | Flag parsing loop                          |
| `dart:io` `File` class             | `saveArticleToFile()`                      |
| `StringBuffer`                     | Efficient string building for file content |
| `List<String>.from()`              | Converting `List<dynamic>` to typed list   |
| `Future<void>`                     | Async function with no return value        |
| Triple-quoted strings `'''`        | Multi-line `printUsage()` output           |

###Note that highlighted from the doc

Installation

https://dart.dev/get-dart#install
The Dart SDK includes the libraries and command-line tools that you need to develop Dart command-line, server, and web apps.

Dart Overview
https://dart.dev/overview

1. Build Your First App
   Which command generates a new Dart project with the necessary files and directory structure?
   - Dart create creates and scaffolds a new project. You can also use -t to specify a template, like dart create -t console project_name

   - The dart create command generates a basic Dart project named "cli" (for Command Line Interface). It sets up the essential files and directories you need.

---

In a code editor, open the bin/cli.dart file.
The bin/ directory is where your executable code lives. cli.dart is the entry point of your application.
Inside, you'll see the main function. Every Dart program starts executing from its main function.

Run the main function by using dart run

2. Add interactivity to your app
   - Get to know Dart syntax.

   - Learn how to read user input, print usage information, and create a basic command-line interaction.

3. Write Asynchronous Code
   - Explore asynchronous programming in Dart, allowing your applications to perform multiple tasks concurrently.
   - Learn how to fetch data from the internet using the http package, to retrieve an article summary from Wikipedia.

   - Note:Open the dartpedia/cli/pubspec.yaml file within your project. This file is called the pubspec, and it manages your Dart project's metadata, dependencies (like the http package), and assets.

   - The async keyword marks a function as asynchronous, allowing it to use await to wait for asynchronous operations.

   - A Future is like a promise. It represents a value that isn't available yet but will be once an asynchronous operation (like a network request) finishes.
   - await pauses the execution of the function until the Future is completed.

   - This is the key benefit of async programming. While waiting for one operation, Dart's event loop can handle other work, keeping your app responsive.
