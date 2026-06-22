import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static const String _model = 'meta-llama/llama-3-8b-instruct:nitro';

  /// Performs an HTTP POST request to get chat completions.
  /// It first tries the local backend. If it fails or times out, it falls back to OpenRouter directly.
  static Future<http.Response> postRequest({
    required Map<String, dynamic> body,
  }) async {
    final backendUrl = '${AppConstants.backendBaseUrl}/api/chat';
    try {
      print('📡 Attempting API call via backend: $backendUrl');
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return response;
      }
      print('⚠️ Backend returned status ${response.statusCode}, trying direct OpenRouter...');
    } catch (e) {
      print('⚠️ Backend request failed: $e. Falling back to direct OpenRouter...');
    }

    // Fallback: Call OpenRouter directly
    final directUrl = AppConstants.openRouterApiUrl;
    final directKey = AppConstants.openRouterApiKey;
    print('📡 Attempting direct API call to OpenRouter: $directUrl');
    
    return await http.post(
      Uri.parse(directUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $directKey',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await postRequest(
        body: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': message}
          ],
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return {'response': content, 'status': 'success'};
      } else {
        return {'error': 'Server error: ${response.statusCode}', 'status': 'error'};
      }
    } catch (e) {
      return {'error': 'Connection failed: $e', 'status': 'error'};
    }
  }
}