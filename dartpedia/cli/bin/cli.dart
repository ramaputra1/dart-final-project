//The value of a const variable can never be changed after it's been set.
const version = '0.0.1'; 

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help'){  //dart bin/cli.dart
    printUsage();
  } else if (arguments.first == 'version') {  //dart bin/cli.dart version
    //The $version syntax is called string interpolation. 
    //It lets you embed the value of the variable directly into a string by prefixing the variable name with a $ sign.
    print('Dartpedia CLI version $version');
  } else if (arguments.first == 'search') {
    print('Search command recognized!');
  } else{
    printUsage();  // Catch-all for any unrecognized command.
  }
}
//Learn: List manipulation, null checks, and string interpolation.
//List<String>? arguments means that the arguments list itself can be null
void searchWikipedia(List<String>? arguments) {
  print('searchingWikipedia received arguments: $arguments');
}

void printUsage(){  //printUsage Function: To make the output more user-friendly, create a separate function to display usage information. 
  print(  //search is the command that will eventually search from Wikipedia.
    "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'"
  );
}

/*
Understand the if/else structure and variables:
arguments.isEmpty checks if no command-line arguments were provided.
arguments.first accesses the very first argument, which you're using as our command.
version is declared as a const. This means its value is known at compile time, and you can't change it during runtime.
arguments is a regular (non-constant) variable because its content can change during runtime based on user input.
*/