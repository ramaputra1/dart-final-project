import 'dart:io'; // is a core library in the Dart SDK, and provides APIs to deal with files, directories, sockets, and HTTP clients and servers, and more.

const version = '0.0.1'; // const var for check the version of cli

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') { // implement help
    printUsage();
  } else if (arguments.first == 'version') {
    print('Dartpedia CLI version: $version');
    // The $version syntax is called string interpolation. It lets you embed the value of the variable directly into a string by prefixing the variable name with a $ sign.s
  } else if (arguments.first == 'search') { // search cmd
    final inputArgs = arguments.length > 1 ? arguments.sublist(1) : null;
    // final var only set once and never change the var again
    // arguments.sublist(1) creates a new list containing all elements of the arguments list after the first element (which was search).
    // arguments.length > 1 ? ... : null; is a conditional (ternary) operator. It ensures that if no arguments are provided after the search command, inputArgs becomes null, matching the sample code's behavior for searchWikipedia's arguments parameter of List<String>?.
    searchWikipedia(inputArgs);
  } else {
    printUsage();
  }
}

// function to make the ouutput more userfriendly on our cli
void printUsage() {
  print(
    "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'"
  );
}

// search wikipedia func
void searchWikipedia(List<String>? arguments) { // List<String>? arguments means that the arguments list itself can be null.
  final String articleTitle;

  // If the user didn't pass in arguments, request an article title.
  if (arguments == null || arguments.isEmpty) {
    print('Please provide an article title.');
    // Await input and provide a default empty string if the input is null.
    articleTitle = stdin.readLineSync() ?? '';
  } else {
    // Otherwise, join the arguments into the CLI into a single string
    articleTitle = arguments.join(' ');
  }

  print('Looking up articles about "$articleTitle". Please wait.');
  print('Here ya go!');
  print('(Pretend this is an article about "$articleTitle")');
}




