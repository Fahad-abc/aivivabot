import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class NotesService {
  // ✅ Using AppConstants.backendBaseUrl (same as Viva/GeminiService)
  static String get _backendUrl => '${AppConstants.backendBaseUrl}/api/chat';

  static Future<String> generateNotes({
    required String documentContent,
  }) async {
    print('📡 Notes - Backend URL: $_backendUrl');
    print('📄 Notes - Document Length: ${documentContent.length}');

    final prompt = '''
Document: $documentContent

Create VERY DETAILED study notes following these rules:

1. Write LONG, THOROUGH explanations (5-10 sentences per concept)
2. Add FULL code examples with line-by-line comments
3. Include 2-3 real-world examples per topic
4. List common mistakes with fixes
5. Add 5-10 key takeaways at the end
6. Use # for titles, ## for sections, ### for subsections
7. Use bullet points and numbered lists
8. Don't skip anything - cover everything

Make notes so detailed that a beginner understands everything perfectly.
''';

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'meta-llama/llama-3-8b-instruct:nitro',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 4000,
        }),
      );

      print('📡 Notes Service Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('choices')) {
          return data['choices'][0]['message']['content'];
        }
        return data.toString();
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('❌ Notes Service Error: $e');
      return 'Error: $e';
    }
  }
}