import 'package:flutter_test/flutter_test.dart';
import 'package:dicto/dicto.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dicto Initialization Tests', () {
    test('Initialize with a single locale string', () async {
      // Initialize with a single locale ("en")
      await Dicto.initialize(localesToInitialize: 'en');
      final response =
          Dicto.get('hello'); // assuming "hello" exists in the English asset
      expect(response, 'en');
    });

    test('Initialize with a list of locales', () async {
      // Initialize with multiple locales
      await Dicto.initialize(localesToInitialize: ['en', 'es']);
      final responseEn = Dicto.get('hello'); // English word
      final responseEs = Dicto.get('hola'); // Spanish word
      expect(responseEn, 'en');
      expect(responseEs, 'es');
    });

    test('Initialization with invalid type should throw ArgumentError',
        () async {
      // Passing a non-string and non-list value should throw an error.
      expect(
        () async => await Dicto.initialize(localesToInitialize: 123),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Re-initializing adds missing locales without reprocessing existing ones',
        () async {
      // First, initialize with only English.
      await Dicto.initialize(localesToInitialize: ['en']);
      final responseEn = Dicto.get('hello');
      expect(responseEn, 'en');

      // Now, re-initialize with English and Spanish.
      // This should add Spanish without affecting existing English entries.
      await Dicto.initialize(localesToInitialize: ['en', 'es']);
      final responseEs = Dicto.get('hola');
      expect(responseEs, 'es');
    });

    test('Lookup without initialization throws exception', () {
      // Reset the database for testing purposes.
      Dicto.resetForTesting();
      expect(() => Dicto.get('hello'), throwsException);
    });
  });

  group('Dicto Lookup Tests', () {
    // Ensure a clean initialization for these lookup tests.
    setUpAll(() async {
      await Dicto.initialize(localesToInitialize: ['en', 'es', 'de']);
    });

    test('Lookup word in English dictionary', () {
      final response = Dicto.get('hello');
      expect(response, 'en');
    });

    test('Lookup word in Spanish dictionary', () {
      final response = Dicto.get('hola');
      expect(response, 'es');
    });

    test('Lookup word in German dictionary', () {
      final response = Dicto.get('hallo');
      expect(response, 'de');
    });

    test('Lookup is case-insensitive', () {
      final response = Dicto.get('HeLLo');
      expect(response, 'en');
    });

    test('Lookup non-existent word returns invalid', () {
      final response = Dicto.get('qwertyuiop');
      expect(response, '');
    });
  });
}
