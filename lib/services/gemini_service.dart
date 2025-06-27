// lib/services/gemini_service.dart
import 'dart:convert';
import 'package.flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r3/secrets.dart'; // Import our secret API key

class GeminiService {
  final String _apiKey = geminiApiKey;
  final String _model = "gemini-1.5-flash-latest"; // Or another model you prefer

  Future<String> getLearningTopic(String topic) async {
    final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey");

    // This is the prompt we are sending to the AI
    final prompt = "Explain the absolute basics of '$topic' in about 150 words, as if you were teaching a complete beginner. Make it engaging and easy to understand.";

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // The response text is nested deep inside the JSON.
        final text = responseBody['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        if (kDebugMode) {
          print("API Error: ${response.body}");
        }
        return "Error: Could not get a response from the AI. Status code: ${response.statusCode}";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Network Error: $e");
      }
      return "Error: A network problem occurred. Please check your connection.";
    }
  }
}