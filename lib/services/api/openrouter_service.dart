import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  // API key from environment variable (set during build)
  static String get _apiKey => const String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<Map<String, dynamic>> chat(String prompt) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'deepseek/deepseek-r1:free',
        'messages': [{'role': 'user', 'content': prompt}],
      }),
    );
    return jsonDecode(response.body);
  }
}