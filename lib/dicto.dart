import 'package:sqlite3/sqlite3.dart';
import 'src/dicto_impl.dart';

/// Dicto is the public API for the dictionary package.
class Dicto {
  static Database? _db;

  /// Returns true if Dicto has been initialized.
  static bool get isInitialized => _db != null;

  /// Initializes Dicto for the given locales.
  /// [localesToInitialize] can be a single locale string or a list of Strings.
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
    // Only initialize if not already done.
    if (!isInitialized) {
      _db = await initializeDatabaseImpl(localesToInitialize: locales);
    }
    // Optionally, update missing locales if desired.
  }

  /// Performs a lookup for [word] in the active database.
  /// Returns the locale if found, or an empty string if not.
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

  /// Deletes all other locales from the database and keeps only the specified [locale].
  /// If the database is not initialized, it initializes with the given locale.
  static Future<void> syncLocale(String locale) async {
    if (!isInitialized) {
      await initialize(localesToInitialize: locale);
      return;
    }
    await syncLocaleImpl(_db!, locale);
  }

  /// Resets the internal database (for testing purposes).
  static void resetForTesting() {
    _db = null;
  }
}
