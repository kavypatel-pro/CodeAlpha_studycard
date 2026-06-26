import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/flashcard.dart';

class FlashcardApiService {
  static const String _model = 'gemini-2.5-flash';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  /// Fetches a list of flashcards from the Google Gemini API with exponential backoff retries.
  Future<List<Flashcard>> fetchFlashcards() async {
    final String? apiKey = dotenv.env['FLASHCARD_API_KEY'];
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception('API key not found. Ensure FLASHCARD_API_KEY is defined in your .env file.');
    }

    final Uri url = Uri.parse('$_baseUrl?key=$apiKey');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': 'Generate a list of 10 diverse educational flashcards for study. '
                  'The output must be a valid JSON array of objects. Do not wrap in markdown tags like ```json. '
                  'Each object MUST contain these exact keys: '
                  '"id" (unique string), "question" (string), "answer" (string), "category" (string). '
                  'The "category" value MUST be exactly one of: "Programming", "Science", "Mathematics", "History", or "General Knowledge".'
            }
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
      }
    };

    int retries = 3;
    Duration delay = const Duration(seconds: 2);

    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final http.Response response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
          final String rawText = responseData['candidates'][0]['content']['parts'][0]['text'] as String;

          // Strip markdown code blocks if the model somehow returned them anyway
          String cleanedText = rawText.trim();
          if (cleanedText.startsWith('```')) {
            // Remove starting ```json or ```
            final lines = cleanedText.split('\n');
            if (lines.first.startsWith('```')) {
              lines.removeAt(0);
            }
            if (lines.last.startsWith('```')) {
              lines.removeLast();
            }
            cleanedText = lines.join('\n').trim();
          }

          final List<dynamic> jsonList = jsonDecode(cleanedText) as List<dynamic>;
          
          return jsonList.map((item) {
            final map = item as Map<String, dynamic>;
            // Add a createdAt timestamp for compatibility with the Flashcard model
            return Flashcard(
              id: map['id']?.toString() ?? 'api-${DateTime.now().millisecondsSinceEpoch}-${jsonList.indexOf(item)}',
              question: map['question']?.toString() ?? 'Empty Question',
              answer: map['answer']?.toString() ?? 'Empty Answer',
              category: map['category']?.toString() ?? 'General Knowledge',
              isFavorite: false, // Pulled from API, default not favorited
              createdAt: DateTime.now(),
            );
          }).toList();
        } else {
          // If status code is 429 (Rate Limit) or server errors, retry
          if (response.statusCode == 429 || response.statusCode >= 500) {
            if (attempt == retries) {
              throw Exception('API returned status code ${response.statusCode}: ${response.reasonPhrase}');
            }
          } else {
            // Unrecoverable status codes (e.g. 400, 403)
            throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
          }
        }
      } catch (e) {
        if (attempt == retries) {
          rethrow;
        }
      }

      // Exponential backoff
      await Future.delayed(delay);
      delay = delay * 2;
    }

    throw Exception('Failed to load flashcards after multiple attempts.');
  }
}
