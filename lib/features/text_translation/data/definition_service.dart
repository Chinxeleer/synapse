import 'dart:convert';
import 'package:http/http.dart' as http;

class DefinitionService {
  static const String _baseUrl = 'https://ocr-76ba.onrender.com/';

  static Future<String> defineWord(String word) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/define-word?word=${Uri.encodeComponent(word)}',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Adjust this field name to match your API's response shape
        return json['definition'] ?? json['meaning'] ?? 'No definition found';
      } else {
        throw Exception('API error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not fetch definition: $e');
    }
  }
}