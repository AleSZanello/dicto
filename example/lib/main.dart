import 'package:flutter/material.dart';
import 'package:dicto/dicto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Dicto with English and Spanish for this example.
  await Dicto.initialize(localesToInitialize: ['en', 'es']);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dicto Example',
      home: DictoExampleScreen(),
    );
  }
}

class DictoExampleScreen extends StatefulWidget {
  @override
  _DictoExampleScreenState createState() => _DictoExampleScreenState();
}

class _DictoExampleScreenState extends State<DictoExampleScreen> {
  final TextEditingController _controller = TextEditingController();
  String _lookupResult = '';

  void _lookupWord() {
    final word = _controller.text;
    final response = Dicto.get(word);
    setState(() {
      _lookupResult = response.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dicto Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a word',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _lookupWord,
              child: Text('Lookup Word'),
            ),
            SizedBox(height: 20),
            Text(
              'Result: $_lookupResult',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
