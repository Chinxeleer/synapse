import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationCameraService {
  static const String _baseUrl = 'https://ocr-76ba.onrender.com';

  /// Sends an image file to your API and returns the translation result.
  /// [imageFile] - the captured/picked image
  /// [targetLanguage] - optional language code e.g. 'en', 'fr'
  static Future<TranslationResult> translateImageText({
    required File imageFile,
    String targetLanguage = 'en',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/ocr-translate');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',               // field name your API reads
          imageFile.path,
          // The MIME type tells the server what kind of file this is
          // For JPEG captures use 'image/jpeg', PNG use 'image/png'
        ),
      );

      // Add any extra fields your API needs
      request.fields['target_language'] = targetLanguage;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30), // Don't wait forever incase the network is bad
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return TranslationResult(
          extractedText: json['extracted_text'] ?? '',
          translatedText: json['translated_text'] ?? '',
          sourceLanguage: json['english'] ?? 'unknown',
          targetLanguage: targetLanguage,
        );
      } else {
        throw ApiException(
          'API returned ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
}

// Clean data model for results
class TranslationResult {
  final String extractedText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;

  const TranslationResult({
    required this.extractedText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
  });
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}