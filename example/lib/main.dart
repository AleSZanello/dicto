import 'package:flutter/material.dart';
import 'package:dicto/dicto.dart';

void main() async {
  // Ensure Flutter widgets are initialized before calling asynchronous methods.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Dicto with English and Spanish dictionaries for this example.
  await Dicto.initialize(localesToInitialize: ['en', 'es']);
  runApp(const MyApp());
}

/// The root widget of the example application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Dicto Example',
      home: DictoExampleScreen(),
    );
  }
}

/// A screen that demonstrates the various Dicto functionalities.
class DictoExampleScreen extends StatefulWidget {
  const DictoExampleScreen({super.key});

  @override
  _DictoExampleScreenState createState() => _DictoExampleScreenState();
}

class _DictoExampleScreenState extends State<DictoExampleScreen> {
  // Controllers for text input fields.
  final TextEditingController _lookupController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Variables to hold the output for each operation.
  String _lookupResult = '';
  String _randomWord = '';
  String _countResult = '';
  List<String> _searchResults = [];

  // List of supported locales (must match those provided during initialization).
  final List<String> _locales = ['en', 'es'];
  String _selectedLocale = 'en'; // Default locale selection.

  /// Looks up the entered word and displays the locale it was found in.
  void _lookupWord() {
    final word = _lookupController.text;
    final response = Dicto.get(word);
    setState(() {
      _lookupResult =
          response.isNotEmpty ? 'Found in locale: $response' : 'Word not found';
    });
  }

  /// Fetches a random word from the selected locale.
  void _fetchRandomWord() {
    try {
      final random = Dicto.getRandomWord(_selectedLocale);
      setState(() {
        _randomWord = random;
      });
    } catch (e) {
      setState(() {
        _randomWord = 'Error: ${e.toString()}';
      });
    }
  }

  /// Counts the total number of words in the selected locale.
  void _countWords() {
    try {
      final count = Dicto.countWords(_selectedLocale);
      setState(() {
        _countResult = 'Total words in $_selectedLocale: $count';
      });
    } catch (e) {
      setState(() {
        _countResult = 'Error: ${e.toString()}';
      });
    }
  }

  /// Searches for words containing the given query substring.
  void _searchWords() {
    final query = _searchController.text;
    final results = Dicto.searchWords(query, locale: _selectedLocale);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dicto Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select the locale.
            Row(
              children: [
                const Text(
                  'Select Locale:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedLocale,
                  items: _locales.map((locale) {
                    return DropdownMenuItem(
                      value: locale,
                      child: Text(locale.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLocale = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ------------------------------
            // Word Lookup Section
            // ------------------------------
            const Text(
              'Lookup Word',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lookupController,
              decoration: const InputDecoration(
                labelText: 'Enter a word to lookup',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _lookupWord,
              child: const Text('Lookup'),
            ),
            const SizedBox(height: 10),
            Text(_lookupResult, style: const TextStyle(fontSize: 16)),
            const Divider(height: 40),
            // ------------------------------
            // Random Word Section
            // ------------------------------
            const Text(
              'Random Word',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchRandomWord,
              child: const Text('Get Random Word'),
            ),
            const SizedBox(height: 10),
            Text(_randomWord, style: const TextStyle(fontSize: 16)),
            const Divider(height: 40),
            // ------------------------------
            // Count Words Section
            // ------------------------------
            const Text(
              'Count Words',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _countWords,
              child: const Text('Count Words'),
            ),
            const SizedBox(height: 10),
            Text(_countResult, style: const TextStyle(fontSize: 16)),
            const Divider(height: 40),
            // ------------------------------
            // Search Words Section
            // ------------------------------
            const Text(
              'Search Words',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter search query',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchWords,
              child: const Text('Search'),
            ),
            const SizedBox(height: 10),
            _searchResults.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _searchResults
                        .map((word) =>
                            Text(word, style: const TextStyle(fontSize: 16)))
                        .toList(),
                  )
                : const Text('No search results',
                    style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
