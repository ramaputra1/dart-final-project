//The value of a const variable can never be changed after it's been set.
const version = '0.0.1'; 

void main(List<String> arguments) {
  if (arguments.isEmpty){  //dart bin/cli.dart
    print('Hello world! Hello everyone! Hello Dart!');
  } else if (arguments.first == 'version') {  //dart bin/cli.dart version
    //The $version syntax is called string interpolation. 
    //It lets you embed the value of the variable directly into a string by prefixing the variable name with a $ sign.
    print('Dartpedia CLI version $version');
  }
}

void printUsage(){  //printUsage Function: To make the output more user-friendly, create a separate function to display usage information. 
  print(  //search is the command that will eventually search from Wikipedia.
    "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'"
  );


}
