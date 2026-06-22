//dart:io is a core library in the Dart SDK, and provides APIs to deal with files, directories, sockets, and HTTP clients and servers, and more.
import 'dart:io';
//After add the http package in pubspec.yaml, import it here.
/*
This line imports the http package and gives it the alias http. 
After you do this, you can refer to classes and functions within the http package using http. (for example, http.Client, http.get). 
The as http part is a standard convention to avoid naming conflicts if another imported library also has a similarly named class or function.
*/
import 'package:http/http.dart' as http;

//The value of a const variable can never be changed after it's been set.
const version = '0.0.1'; 

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help'){  //dart bin/cli.dart
    printUsage();
  } else if (arguments.first == 'version') {  //dart bin/cli.dart version
    //The $version syntax is called string interpolation. 
    //It lets you embed the value of the variable directly into a string by prefixing the variable name with a $ sign.
    print('Dartpedia CLI version $version');
  } else if (arguments.first == 'search') {  //dart bin/cli.dart search <ARTICLE-TITLE>
    //Use arguments.sublist(1) to get all arguments starting from the second one. If no arguments are provided after search, pass null to searchWikipedia.
    final inputArgs = arguments.length > 1 ? arguments.sublist(1) : null;
    searchWikipedia(inputArgs);
  } else{
    printUsage();  // Catch-all for any unrecognized command.
  }
}
//Learn: List manipulation, null checks, and string interpolation.
//List<String>? arguments means that the arguments list itself can be null
void searchWikipedia(List<String>? arguments) async{  //This is essential because it will call getWikipediaArticle, which is an async function itself and will need to await its result.
  final String articleTitle;
  //If the user did not pass in arguments, request an article title.
  if (arguments == null || arguments.isEmpty) {
    print('Please provide an article title.');
    // Read input without the `?? ''` fallback.
    final inputFromStdin = stdin.readLineSync();
    if (inputFromStdin == null || inputFromStdin.isEmpty) {
      print('No article title provided. Exiting.');
      return; // Exit the function if there's no valid input.
    }
    articleTitle = inputFromStdin;
    //Await input and provide a default empty string if the input is null.
    //articleTitle = stdin.readLineSync() ?? '';
  } else {
    //Otherwise, join the arguments into a single string.
    articleTitle = arguments.join(' ');
  }


  print('Looking up articles about "$articleTitle". Please wait.');
  // Call the API and await the result.
  var articleContent = await getWikipediaArticle(articleTitle);
  print(articleContent); // Print the full article response (raw JSON for now)
}

void printUsage(){  //printUsage Function: To make the output more user-friendly, create a separate function to display usage information. 
  print(  //search is the command that will eventually search from Wikipedia.
    "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'"
  );
}

//It handles fetching data from an external API. This function will be async because network requests are asynchronous operations.
Future<String> getWikipediaArticle(String articleTitle) async {
//The Uri represents the endpoint of the Wikipedia API that you'll be calling to get an article summary.
  final url = Uri.https(
    'en.wikipedia.org', //Wikipedia API domain
    '/api/reat_v1/page/summary/$articleTitle', //API path for article summary
  );
  final response = await http.get(url);  //Make the HTTP request

  if (response.statusCode == 200) {
    return response.body;  //Return the response body if successful
  } 
  //Return an error message if the request failed
  return 'Error: Failed to fetch article "$articleTitle". Status  code: ${response.statusCode}';
}


/*
Understand the if/else structure and variables:
arguments.isEmpty checks if no command-line arguments were provided.
arguments.first accesses the very first argument, which you're using as our command.
version is declared as a const. This means its value is known at compile time, and you can't change it during runtime.
arguments is a regular (non-constant) variable because its content can change during runtime based on user input.
*/

/*
final variables can only be set once and are used when you never intend to change the variable again in the code.
arguments.sublist(1) creates a new list containing all elements of the arguments list after the first element (which was search).
arguments.length > 1 ? ... : null; is a conditional (ternary) operator. It ensures that if no arguments are provided after the search command, inputArgs becomes null, matching the sample code's behavior for searchWikipedia's arguments parameter of List<String>?.
*/

/*
stdin.readLineSync() ?? '' reads the input from the user. While stdin.readLineSync() can return null, the null-coalescing operator (??) is used to provide an empty string ('') as a fallback if the input is null. This is a concise way to ensure that the variable is a non-null string.
arguments.join(' ') concatenates all elements of the arguments list into a single string, using a space as the separator. For example, ['Dart', 'Programming'] becomes "Dart Programming". This is crucial for treating multi-word command-line inputs as a single search phrase.
Dart static analysis can detect that articleTitle is guaranteed to be initialized when the print statement is executed. No matter which path is taken through this function body, the variable is non-nullable.
*/

/*
The Future<String> return type indicates that this function will eventually produce a String result, but not immediately, because it's an asynchronous operation.
The async keyword marks the function as asynchronous, allowing you to use await inside it.
*/

/*
Use the top-level get function from package:http to make an HTTP GET request to the URL you just constructed. 
The await keyword pauses the execution of getWikipediaArticle until the get call completes and returns an http.Response object.
After the request completes, check the response.statusCode to ensure the request was successful (a status code of 200 means OK). 
If successful, return the response.body, which contains the fetched data (in this case, raw JSON). If the request fails, return an informative error message.
*/
/*
await getWikipediaArticle(articleTitle): Because getWikipediaArticle is an async function, you need to await its result. This pauses the searchWikipedia function until the Future<String> returned by getWikipediaArticle resolves into a String containing the article's contents.
print(articleContent): Prints the fetched article summary as a raw JSON string to the console.
*/