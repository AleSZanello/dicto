import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Attempts to load a dictionary asset for the given locale.
/// First, it tries to load a compressed asset (words_[locale].txt.gz).
/// If that fails, it falls back to the uncompressed asset (words_[locale].txt).
Future<String> loadDictionaryAsset(String locale) async {
  final String gzAssetPath = 'assets/dictionaries/words_${locale}.txt.gz';
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
/// Only the provided [localesToInitialize] are processed.
/// If the database already exists, it checks which locales are missing and adds them.
Future<Database> initializeDatabase({required List<String> localesToInitialize}) async {
  // Obtain the application documents directory.
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final String dbPath = join(documentsDir.path, "dictionary.db");
  final File dbFile = File(dbPath);

  // Open (or create) the database.
  final Database db = sqlite3.open(dbPath);

  // Ensure that the dictionary table exists.
  final tableCheck = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='dictionary';");

  if (tableCheck.isEmpty) {
    // If the table doesn't exist, create it.
    print("Dictionary table missing. Creating new table.");
    db.execute('''
      CREATE TABLE dictionary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        locale TEXT NOT NULL
      );
    ''');
    db.execute('CREATE INDEX idx_locale_word ON dictionary(locale, word COLLATE NOCASE);');
  }

  // Check for missing locales in the existing table.
  final ResultSet existingLocalesResult = db.select('SELECT DISTINCT locale FROM dictionary;');
  final existingLocales = existingLocalesResult.map((row) => row['locale'] as String).toSet();
  final missingLocales = localesToInitialize.where((l) => !existingLocales.contains(l));

  // Process missing locales only.
  for (final locale in missingLocales) {
    print("Locale $locale missing in DB. Processing asset for this locale.");
    try {
      final String content = await loadDictionaryAsset(locale);
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
      print("Error processing locale $locale: $e");
    }
  }

  return db;
}

/// Example Dicto initialization class.
class Dicto {
  static Database? _db;

  /// Initializes the Dicto package for the given locales.
  /// [localesToInitialize] can be a single-locale string or a List of Strings.
  static Future<void> initialize({required dynamic localesToInitialize}) async {
    List<String> locales;
    if (localesToInitialize is String) {
      locales = [localesToInitialize];
    } else if (localesToInitialize is List<String>) {
      locales = localesToInitialize;
    } else {
      throw ArgumentError(
          "localesToInitialize must be either a String or a List<String>");
    }
    _db = await initializeDatabase(localesToInitialize: locales);
    // Optionally, verify that at least one locale is present.
  }

  /// Performs a lookup for [word] in the active database.
  /// Returns the locale if the word is found, or an empty string if not.
  static String Get(String word) {
    if (_db == null) {
      throw Exception("Dicto not initialized. Call Dicto.initialize() first.");
    }
    final String lowerWord = word.toLowerCase();
    final ResultSet result = _db!.select(
      'SELECT locale FROM dictionary WHERE word = ? LIMIT 1;',
      [lowerWord],
    );
    if (result.isNotEmpty) {
      final locale = result.first['locale'] as String;
      return locale;
    } else {
      return '';
    }
  }

  /// Resets the internal database.
  /// This method is intended for testing purposes.
  static void resetForTesting() {
    _db = null;
  }
}
