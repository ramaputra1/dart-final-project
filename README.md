# dart-final-project

Final Project for CS420 course BYUH that teach by Bro. Slade. Purpose to learn dart as programming language.

##Lok Yiu Chan (Momo)

###Phase 1 - Dart Official Docs Tutorial

For Phase 1, I followed the official Dart tutorials from its Documentation (On their official website) Dart Official Tutorial. I completed 1-3. That includes:

1. Build Your First App
2. Add Interactivity to Your App
3. Write Asynchronous Code

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
