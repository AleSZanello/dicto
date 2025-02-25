import 'package:sqlite3/sqlite3.dart';
import 'src/dicto_database.dart';

/// Dicto is the public API for the dictionary package.
///
/// This package allows you to initialize a dictionary database with word lists
/// for specific locales, perform lookups, search for words, and retrieve random words.
/// All words are stored in lowercase to enable case‑insensitive searches.
class Dicto {
  static Database? _db;

  /// Returns true if Dicto has been initialized.
  static bool get isInitialized => _db != null;

  /// Initializes Dicto for the given locales.
  ///
  /// [localesToInitialize] can be a single locale (as a String) or a list of locales.
  /// This method loads the dictionary assets for the provided locales and ensures
  /// that the database contains only the locales specified.
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
    if (_db == null) {
      _db = await initializeDatabase(localesToInitialize: locales);
    } else {
      await updateLocales(_db!, localesToInitialize: locales);
    }
  }

  /// Performs a lookup for [word] in the active database.
  ///
  /// Returns the locale in which the word is found, or an empty string if not.
  static String get(String word) {
    if (!isInitialized) {
      throw Exception("Dicto not initialized. Call Dicto.initialize() first.");
    }
    final String lowerWord = word.toLowerCase();
    final ResultSet result = _db!.select(
      'SELECT locale FROM dictionary WHERE word = ? LIMIT 1;',
      [lowerWord],
    );
    if (result.isNotEmpty) {
      return result.first['locale'] as String;
    } else {
      return '';
    }
  }

  /// Deletes all locales from the database and re‑initializes it with the specified [locale].
  ///
  /// If the database is not yet initialized, it calls [initialize] with the given locale.
  /// This is useful if you want to have only a single locale in the database.
  static Future<void> syncLocale(String locale) async {
    if (!isInitialized) {
      await initialize(localesToInitialize: locale);
      return;
    }
    await syncLocaleInDatabase(_db!, locale);
  }

  /// Resets the internal database (for testing purposes).
  static void resetForTesting() {
    _db = null;
  }

  /// Returns the total number of words in the dictionary for the given [locale].
  ///
  /// Queries the database for the count of words belonging to the specified locale.
  static int countWords(String locale) {
    if (!isInitialized) {
      throw Exception("Dicto not initialized. Call Dicto.initialize() first.");
    }
    final ResultSet result = _db!.select(
      'SELECT COUNT(*) as count FROM dictionary WHERE locale = ?;',
      [locale],
    );
    return result.first['count'] as int;
  }

  /// Searches for words containing the [query] substring.
  ///
  /// Optionally filters by [locale] if provided.
  /// Returns a list of matching words.
  static List<String> searchWords(String query, {String? locale}) {
    if (!isInitialized) {
      throw Exception("Dicto not initialized. Call Dicto.initialize() first.");
    }
    final String lowerQuery = query.toLowerCase();
    String sql = 'SELECT word FROM dictionary WHERE word LIKE ?';
    List<dynamic> params = ['%$lowerQuery%'];
    if (locale != null) {
      sql += ' AND locale = ?';
      params.add(locale);
    }
    final ResultSet result = _db!.select(sql, params);
    return result.map((row) => row['word'] as String).toList();
  }

  /// Returns a random word from the dictionary for the given [locale].
  ///
  /// Useful for features like "Word of the Day" or random word challenges.
  static String getRandomWord(String locale) {
    if (!isInitialized) {
      throw Exception("Dicto not initialized. Call Dicto.initialize() first.");
    }
    final ResultSet result = _db!.select(
      'SELECT word FROM dictionary WHERE locale = ? ORDER BY RANDOM() LIMIT 1;',
      [locale],
    );
    if (result.isNotEmpty) {
      return result.first['word'] as String;
    }
    throw Exception('No words found for locale $locale.');
  }
}
