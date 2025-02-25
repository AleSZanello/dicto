import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Attempts to load a dictionary asset for the given locale.
/// First, it tries to load a compressed asset (words_[locale].txt.gz).
/// If that fails, it falls back to the uncompressed asset (words_[locale].txt).
Future<String> loadDictionaryAssetImpl(String locale) async {
  final String gzAssetPath = 'packages/dicto/assets/dictionaries/words_$locale.txt.gz';
  try {
    final ByteData byteData = await rootBundle.load(gzAssetPath);
    final List<int> compressedBytes = byteData.buffer.asUint8List();
    final List<int> decompressedBytes = GZipCodec().decode(compressedBytes);
    return String.fromCharCodes(decompressedBytes);
  } catch (e) {
    // Fallback to the uncompressed asset if the compressed file isn't found.
    throw Exception("Error loading compressed asset: $e");
  }
}

/// Initializes (or opens) the SQLite database.
/// Processes only the provided [localesToInitialize]. If the database already exists,
/// it checks which locales are missing and adds them.
Future<Database> initializeDatabaseImpl(
    {required List<String> localesToInitialize}) async {
  // Obtain the application documents directory.
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final String dbPath = join(documentsDir.path, "dictionary.db");

  // Open (or create) the database.
  final Database db = sqlite3.open(dbPath);

  // Ensure that the dictionary table exists.
  final tableCheck = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='dictionary';");

  if (tableCheck.isEmpty) {
    // If the table doesn't exist, create it.
    db.execute('''
      CREATE TABLE dictionary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        locale TEXT NOT NULL
      );
    ''');
    db.execute(
        'CREATE INDEX idx_locale_word ON dictionary(locale, word COLLATE NOCASE);');
  }

  // Check for missing locales in the existing table.
  final ResultSet existingLocalesResult =
      db.select('SELECT DISTINCT locale FROM dictionary;');
  final existingLocales =
      existingLocalesResult.map((row) => row['locale'] as String).toSet();
  final missingLocales =
      localesToInitialize.where((l) => !existingLocales.contains(l));

  // Process missing locales only.
  for (final locale in missingLocales) {
    try {
      final String content = await loadDictionaryAssetImpl(locale);
      final List<String> lines = content.split('\n');

      db.execute('BEGIN TRANSACTION;');
      for (final line in lines) {
        final String word = line.trim();
        if (word.isNotEmpty) {
          // Insert the word in lowercase.
          db.execute(
            'INSERT INTO dictionary (word, locale) VALUES (?, ?);',
            [word.toLowerCase(), locale],
          );
        }
      }
      db.execute('COMMIT;');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  return db;
}

/// Internal function to sync the database with only the provided locale.
/// It deletes all rows if any other locale is found and inserts the asset for [locale].
Future<void> syncLocaleImpl(Database db, String locale) async {
  // Check if the dictionary table exists.
  final tableCheck = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='dictionary';");
  if (tableCheck.isEmpty) {
    // Table doesn't exist; nothing to do.
    return;
  }

  // Get the set of locales currently in the table.
  final ResultSet localesResult =
      db.select("SELECT DISTINCT locale FROM dictionary;");
  final existingLocales =
      localesResult.map((row) => row['locale'] as String).toSet();

  if (existingLocales.length == 1 && existingLocales.contains(locale)) {
    // Only the desired locale exists; nothing to do.
    return;
  } else {
    // Delete all rows from the dictionary table.
    db.execute("DELETE FROM dictionary;");

    // Insert the words for the provided locale.
    try {
      final String content = await loadDictionaryAssetImpl(locale);
      final List<String> lines = content.split('\n');

      db.execute('BEGIN TRANSACTION;');
      for (final line in lines) {
        final String word = line.trim();
        if (word.isNotEmpty) {
          db.execute(
            'INSERT INTO dictionary (word, locale) VALUES (?, ?);',
            [word.toLowerCase(), locale],
          );
        }
      }
      db.execute('COMMIT;');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
