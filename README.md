# Dicto

Dicto is a Flutter package that provides fast, multi-lingual dictionary lookups using an SQLite database. On first run, it automatically creates the database by reading (and decompressing) dictionary assets from your app’s assets folder. You can choose which locales to initialize, and if the database already exists it will only add missing locales.

## How It Works

- **Asset Loading:** It first tries to load a compressed asset (e.g. `words_en.txt.gz`) for a given locale. If that fails, it will throw an error.
- **Database Initialization:** The package creates an SQLite database (if one doesn’t already exist) and builds a table with word–locale pairs. If the database already exists, it checks for any missing locales from the provided list and adds only those.
- **Dictionary Lookup:** Once initialized, you can quickly check if a word exists and get its locale.

## Installation

1. Add Dicto to your `pubspec.yaml` dependencies.

   ```yaml
   dependencies:
     dicto: ^0.0.8


## Usage

**Initialization**

In your app’s main() function, initialize Dicto by providing the list of locales you want to include. For example, to initialize English and Spanish:

```dart
import 'package:dicto/dicto.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Dicto.initialize(localesToInitialize: ['en', 'es']);
  runApp(MyApp());
} 
```
Word Lookup

Use Dicto.dictoGet to look up a word:

```dart
final response = Dicto.Get("hello");
print(response); // prints "en" if "hello" exists, or prints an empty string if not.

```

## Code Overview

Below is a simplified summary of the main functions in Dicto:

1. **loadDictionaryAsset(String locale):**
Loads a compressed asset for the given locale (e.g. words_en.txt.gz) and decompresses it.

2. **initializeDatabase({required List<String> localesToInitialize}):**
Creates or opens the SQLite database. It processes only the specified locales and adds missing locales if needed.

3. **Dicto.initialize({required List<String> localesToInitialize}):**
Initializes the package using the database created by initializeDatabase.

4. **Dicto.dictoGet(String word):**
Performs a lookup for the provided word and returns a DictoResponse.

5. **DictoResponse:**
A simple response type of string containing the locale if is a valid word or empty string if the word was not found on any locale initialized on the DB
