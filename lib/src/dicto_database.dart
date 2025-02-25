import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dicto_asset_loader.dart';

/// Initializes (or opens) the SQLite database and processes the provided [localesToInitialize].
///
/// If the database already exists, it will be updated to contain only the locales specified.
/// Returns an instance of the initialized [Database].
Future<Database> initializeDatabase(
    {required List<String> localesToInitialize}) async {
  // Obtain the application documents directory.
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final String dbPath = join(documentsDir.path, "dictionary.db");

  // Open (or create) the SQLite database.
  final Database db = sqlite3.open(dbPath);

  // Check if the dictionary table exists.
  final tableCheck = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='dictionary';");

  if (tableCheck.isEmpty) {
    // Create the table if it doesn't exist.
    db.execute('''
      CREATE TABLE dictionary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        locale TEXT NOT NULL
      );
    ''');
    // Create an index to improve query performance on locale and word.
    db.execute(
        'CREATE INDEX idx_locale_word ON dictionary(locale, word COLLATE NOCASE);');
  }

  // Update the database with the provided locales.
  await updateLocales(db, localesToInitialize: localesToInitialize);

  return db;
}

/// Updates the database to contain only the provided locales.
/// If the current locales in the database differ from [localesToInitialize],
/// the dictionary table is cleared and repopulated with the words for the specified locales.
Future<void> updateLocales(Database db,
    {required List<String> localesToInitialize}) async {
  final ResultSet result = db.select('SELECT DISTINCT locale FROM dictionary;');
  final Set<String> existingLocales =
      result.map((row) => row['locale'] as String).toSet();
  final Set<String> providedLocales = localesToInitialize.toSet();

  // If the existing locales match the provided ones, no update is needed.
  if (existingLocales.length == providedLocales.length &&
      existingLocales.containsAll(providedLocales)) {
    return;
  } else {
    // Clear the dictionary table.
    db.execute("DELETE FROM dictionary;");
    // Insert words for each provided locale.
    for (final locale in providedLocales) {
      try {
        final String content = await loadDictionaryAsset(locale);
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
        db.execute('ROLLBACK;');
        throw Exception('Error updating locale "$locale": $e');
      }
    }
  }
}

/// Synchronizes the database to contain only the specified [locale].
///
/// This function deletes all entries in the dictionary that do not match the given [locale]
/// and reloads the dictionary for that locale from the asset.
Future<void> syncLocaleInDatabase(Database db, String locale) async {
  // Verify that the dictionary table exists.
  final tableCheck = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='dictionary';");
  if (tableCheck.isEmpty) return;

  final ResultSet result = db.select("SELECT DISTINCT locale FROM dictionary;");
  final Set<String> existingLocales =
      result.map((row) => row['locale'] as String).toSet();

  // If only the desired locale exists, no synchronization is needed.
  if (existingLocales.length == 1 && existingLocales.contains(locale)) {
    return;
  } else {
    // Remove all rows to eliminate unwanted locales.
    db.execute("DELETE FROM dictionary;");
    try {
      final String content = await loadDictionaryAsset(locale);
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
      db.execute('ROLLBACK;');
      throw Exception('Error synchronizing locale "$locale": $e');
    }
  }
}
