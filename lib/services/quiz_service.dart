import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class QuizService {
  static String get _backendUrl => '${AppConstants.backendBaseUrl}/api/chat';

  // ============================================================
  // GENERATE SHORT QUESTIONS
  // ============================================================
  static Future<List<Map<String, dynamic>>> generateShortQuestions({
    required String documentContent,
    required int count,
  }) async {
    print('📄 Quiz - Document Length: ${documentContent.length}');
    print('📡 Quiz - Backend URL: $_backendUrl');

    final contentPreview = documentContent.length > 2000
        ? documentContent.substring(0, 2000)
        : documentContent;

    final prompt = '''
Based on the document below, generate $count SHORT ANSWER QUESTIONS with concise (1-2 sentence) ideal answers.

DOCUMENT:
$contentPreview

Return ONLY a JSON array — no preamble, no markdown, no explanations.
Start with [ and end with ].
Keep idealAnswer to 1-2 sentences. Do NOT repeat document text.
Example: [{"id":1,"question":"...","idealAnswer":"..."}]
''';

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'meta-llama/llama-3-8b-instruct:nitro',
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': 0.7,
          'max_tokens': 4096,
        }),
      );

      print('📡 Quiz Service Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          print('📡 AI Raw Response: ${content.substring(0, content.length > 300 ? 300 : content.length)}...');

          final parsed = _parseQuestions(content);
          if (parsed.isNotEmpty) {
            print('✅ Parsed ${parsed.length} questions successfully');
            return parsed;
          }
        }
      }

      print('⚠️ API failed, returning fallback questions');
      return _getFallbackQuestions(count);

    } catch (e) {
      print('❌ Quiz Service Error: $e');
      return _getFallbackQuestions(count);
    }
  }

  // ============================================================
  // GENERATE MCQs
  // ============================================================
  static Future<List<Map<String, dynamic>>> generateMCQs({
    required String documentContent,
    required int count,
  }) async {
    print('📄 Quiz - MCQs - Document Length: ${documentContent.length}');
    print('📡 Quiz - Backend URL: $_backendUrl');

    final contentPreview = documentContent.length > 2000
        ? documentContent.substring(0, 2000)
        : documentContent;

    final prompt = '''
Based on the document below, generate $count MULTIPLE CHOICE QUESTIONS.

DOCUMENT:
$contentPreview

Return ONLY a JSON array — no preamble, no markdown.
Start with [ and end with ].
Keep explanation concise (1 sentence).
Example: [{"id":1,"question":"...","options":["A","B","C","D"],"correct":"B","explanation":"..."}]
''';

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'meta-llama/llama-3-8b-instruct:nitro',
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': 0.7,
          'max_tokens': 4096,
        }),
      );

      print('📡 MCQs Service Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          print('📡 AI Raw Response: ${content.substring(0, content.length > 300 ? 300 : content.length)}...');

          final parsed = _parseMCQs(content);
          if (parsed.isNotEmpty) {
            print('✅ Parsed ${parsed.length} MCQs successfully');
            return parsed;
          }
        }
      }

      print('⚠️ MCQs API failed, returning fallback questions');
      return _getFallbackMCQs(count);

    } catch (e) {
      print('❌ MCQs Error: $e');
      return _getFallbackMCQs(count);
    }
  }

  // ============================================================
  // EVALUATE SHORT ANSWER
  // ============================================================
  static Future<Map<String, dynamic>> evaluateShortAnswer({
    required String question,
    required String userAnswer,
    required String idealAnswer,
  }) async {
    final prompt = '''
Evaluate this answer:

Question: $question
Ideal Answer: $idealAnswer
Student Answer: $userAnswer

Give score from 0-10 and feedback.
Return ONLY JSON: {"score": number, "feedback": "feedback text"}
''';

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'meta-llama/llama-3-8b-instruct:nitro',
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': 0.3,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'];
          return _parseJsonObject(content);
        }
      }
    } catch (e) {
      print('❌ Evaluate error: $e');
    }
    return {'score': 5, 'feedback': 'Answer recorded'};
  }

  // ============================================================
  // FALLBACK QUESTIONS
  // ============================================================
  static List<Map<String, dynamic>> _getFallbackQuestions(int count) {
    print('⚠️ USING FALLBACK QUESTIONS - API NOT WORKING!');
    final fallbacks = [
      {'id': 1, 'question': 'What is the main concept discussed in your document?', 'idealAnswer': 'The document discusses key concepts related to the project.'},
      {'id': 2, 'question': 'Explain the significance of your project.', 'idealAnswer': 'The project is significant because it addresses important challenges.'},
      {'id': 3, 'question': 'What technologies are used in your project?', 'idealAnswer': 'The project uses modern technologies to achieve its goals.'},
      {'id': 4, 'question': 'What are the key features of your project?', 'idealAnswer': 'The key features include functionality that solves real problems.'},
    ];
    return fallbacks.take(count).toList();
  }

  static List<Map<String, dynamic>> _getFallbackMCQs(int count) {
    print('⚠️ USING FALLBACK MCQs - API NOT WORKING!');
    final fallbacks = [
      {
        'id': 1,
        'question': 'What is the main topic of your document?',
        'options': ['Topic A', 'Topic B', 'Topic C', 'Topic D'],
        'correct': 'A',
        'explanation': 'Topic A is the main topic discussed in the document.'
      },
      {
        'id': 2,
        'question': 'What is the primary technology used?',
        'options': ['Technology A', 'Technology B', 'Technology C', 'Technology D'],
        'correct': 'B',
        'explanation': 'Technology B is the primary technology used.'
      },
    ];
    return fallbacks.take(count).toList();
  }

  // ============================================================
  // PARSE HELPERS (FIXED)
  // ============================================================
  static List<Map<String, dynamic>> _parseQuestions(String responseText) {
    try {
      String text = responseText.trim();

      int start = text.indexOf('[');
      if (start == -1) {
        print('⚠️ No JSON array start found');
        return [];
      }

      String jsonStr = text.substring(start);
      int end = jsonStr.lastIndexOf(']');

      // Handle truncated response: last ']' may be missing
      if (end == -1) {
        jsonStr = jsonStr.trimRight();
        if (jsonStr.endsWith(',')) {
          jsonStr = jsonStr.substring(0, jsonStr.length - 1);
        }
        jsonStr = '$jsonStr]';
        end = jsonStr.lastIndexOf(']');
      }

      jsonStr = jsonStr.substring(0, end + 1);
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '');
      jsonStr = jsonStr.replaceAll(RegExp(r'[\r\n]'), ' ');
      jsonStr = jsonStr.replaceAll(RegExp(r'\s+'), ' ');
      jsonStr = jsonStr.trim();

      final List<dynamic> data = jsonDecode(jsonStr);

      return data.map((item) => ({
        'id': item['id'] ?? 0,
        'question': item['question'] ?? item['text'] ?? 'No question',
        'idealAnswer': item['idealAnswer'] ?? item['answer'] ?? 'No answer',
      })).toList();

    } catch (e) {
      print('❌ Parse error: $e');
      print('❌ Raw text: ${responseText.substring(0, responseText.length > 500 ? 500 : responseText.length)}');
      return [];
    }
  }

  static List<Map<String, dynamic>> _parseMCQs(String responseText) {
    try {
      String text = responseText.trim();

      int start = text.indexOf('[');
      if (start == -1) {
        print('⚠️ No JSON array start found');
        return [];
      }

      String jsonStr = text.substring(start);
      int end = jsonStr.lastIndexOf(']');

      if (end == -1) {
        jsonStr = jsonStr.trimRight();
        if (jsonStr.endsWith(',')) {
          jsonStr = jsonStr.substring(0, jsonStr.length - 1);
        }
        jsonStr = '$jsonStr]';
        end = jsonStr.lastIndexOf(']');
      }

      jsonStr = jsonStr.substring(0, end + 1);
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '');
      jsonStr = jsonStr.replaceAll(RegExp(r'[\r\n]'), ' ');
      jsonStr = jsonStr.replaceAll(RegExp(r'\s+'), ' ');
      jsonStr = jsonStr.trim();

      final List<dynamic> data = jsonDecode(jsonStr);
      return data.map((item) => ({
        'id': item['id'] ?? 0,
        'question': item['question'] ?? item['text'] ?? 'No question',
        'options': item['options'] ?? ['A', 'B', 'C', 'D'],
        'correct': item['correct'] ?? 'A',
        'explanation': item['explanation'] ?? 'No explanation',
      })).toList();

    } catch (e) {
      print('❌ Parse MCQ error: $e');
      return [];
    }
  }

  static Map<String, dynamic> _parseJsonObject(String responseText) {
    try {
      String text = responseText.trim();

      int start = text.indexOf('{');
      int end = text.lastIndexOf('}');
      if (start != -1 && end > start) {
        String jsonStr = text.substring(start, end + 1);
        jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
        final data = jsonDecode(jsonStr);
        return Map<String, dynamic>.from(data);
      }
    } catch (e) {
      print('❌ Parse object error: $e');
    }
    return {'score': 5, 'feedback': 'Answer recorded'};
  }
}