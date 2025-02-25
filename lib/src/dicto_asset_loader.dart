import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;

/// Loads and decompresses a dictionary asset for the given [locale].
///
/// Attempts to load a compressed asset (words_[locale].txt.gz) from the package assets.
/// If the asset is not found or an error occurs during decompression, an exception is thrown.
Future<String> loadDictionaryAsset(String locale) async {
  final String gzAssetPath =
      'packages/dicto/assets/dictionaries/words_$locale.txt.gz';
  try {
    final ByteData byteData = await rootBundle.load(gzAssetPath);
    final List<int> compressedBytes = byteData.buffer.asUint8List();
    final List<int> decompressedBytes = GZipCodec().decode(compressedBytes);
    return String.fromCharCodes(decompressedBytes);
  } catch (e) {
    throw Exception("Error loading compressed asset for locale '$locale': $e");
  }
}
