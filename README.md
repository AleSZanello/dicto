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
     dicto: ^0.1.0

## Current languages support

```json
lang_map = {
        "english": "en",
        "spanish": "es",
        "portuguese": "pt",
        "french": "fr",
        "italian": "it",
        "german": "de",
        "russian": "ru",
        "dutch": "nl",
    }
```

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
### Word Lookup

Use Dicto.dictoGet to look up a word:

```dart
final response = Dicto.get("hello");
print(response); // prints "en" if "hello" exists, or prints an empty string if not.

```

### Sync Database to a Specific Locale
If you need to restrict your database to a single locale, use syncLocale to remove all other locales and reload the dictionary for the specified locale:

```dart
await Dicto.syncLocale("en");
```

### Check if the Database Is Initialized
Before performing any operations, you can check whether the database has been initialized:

```dart
if (Dicto.isInitialized) {
  // The dictionary database is ready to use.
}
```

### Additional Helper Functions
Dicto also provides several helper methods for common dictionary operations:

Count Words:
Get the total number of words for a specific locale.

```dart
int totalWords = Dicto.countWords("en");
print("Total words in English: $totalWords");
```

### Search Words:
Search for words containing a specific substring. You can optionally filter by locale.

```dart
List<String> matches = Dicto.searchWords("app", locale: "en");
print("Search results: $matches");
```

### Get a Random Word:
Retrieve a random word from the dictionary for the specified locale.

```dart
String randomWord = Dicto.getRandomWord("en");
print("Random word: $randomWord");
```


## Code Overview

Below is a simplified summary of the main functions in Dicto:

1. **loadDictionaryAsset(String locale):**
Loads and decompresses the dictionary asset for the given locale (e.g. words_en.txt.gz).

2. **initializeDatabase({required List<String> localesToInitialize}):**
Creates or opens the SQLite database and processes only the specified locales. If needed, it adds missing locales.

3. **Dicto.initialize({required dynamic localesToInitialize}):**
Initializes the package using the database from initializeDatabase. Accepts a single locale as a String or a list of locales, ensuring the database contains only the specified locales.

4. **Dicto.get(String word):**
Performs a lookup for the provided word and returns the locale in which the word exists. If the word is not found, it returns an empty string.

5. **Dicto.syncLocale(String locale):**
Synchronizes the database so that only the specified locale exists by deleting all other locales and reloading the corresponding asset.

6. **Additional Helper Methods:**
Synchronizes the database so that only the specified locale exists by deleting all other locales and reloading the corresponding asset.

- ***Dicto.countWords(String locale):*** Returns the total number of words for the specified locale.
- ***Dicto.searchWords(String query, {String? locale}):*** Returns a list of words that match the search query, optionally filtering by locale.
- ***Dicto.getRandomWord(String locale):*** Retrieves a random word from the dictionary for the specified locale.