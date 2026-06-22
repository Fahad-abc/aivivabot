import 'dart:io' show Platform;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

const String targetUrl = 'https://openrouter.ai/api/v1';

void main() async {
  final env = DotEnv()..load();
  final String apiKey = Platform.environment['OPENROUTER_API_KEY'] ?? env['OPENROUTER_API_KEY'] ?? '';

  if (apiKey.isEmpty) {
    print('❌ ERROR: OPENROUTER_API_KEY not set in environment or .env file.');
    return;
  }

  final handler = (Request request) async {
    print('📡 Request: ${request.method} ${request.url.path}');

    // Handle OPTIONS pre-flight requests for CORS
    if (request.method == 'OPTIONS') {
      return Response.ok('OK', headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Authorization, Content-Type',
      });
    }

    // Health check route
    if (request.method == 'GET' && request.url.path == '') {
      return Response.ok(
        '{"status": "VivaBot Proxy Server is running"}',
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    // ✅ ADDED: Health check /health
    if (request.method == 'GET' && request.url.path == 'health') {
      return Response.ok(
        '{"status": "Server is healthy", "timestamp": "${DateTime.now()}"}',
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    // Only allow POST requests for API calls
    if (request.method != 'POST') {
      return Response(
        405,
        body: '{"error": "Only POST requests are allowed"}',
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    try {
      // Read request body
      final String body = await request.readAsString();
      print('📡 Request body: ${body.substring(0, body.length > 300 ? 300 : body.length)}...');

      // Construct the target URL
      final Uri url = Uri.parse('$targetUrl/chat/completions');
      print('📡 Forwarding to: $url');

      // Forward the request
      final client = http.Client();

      try {
        final http.Response response = await client.post(
          url,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'http://localhost:8080',
            'X-Title': 'AI VivaBot',
          },
          body: body,
        );

        print('📡 Response status: ${response.statusCode}');

        return Response(
          response.statusCode,
          body: response.body,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json',
          },
        );
      } finally {
        client.close();
      }
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      return Response(
        500,
        body: '{"error": "Proxy error", "message": "${e.toString()}"}',
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json',
        },
      );
    }
  };

  // ✅ CHANGE: 'localhost' → '0.0.0.0' (so mobile can access)
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('✅ Server running on http://${server.address.host}:${server.port}');
  print('📡 Proxying requests to: $targetUrl/chat/completions');
  print('📱 Mobile: Use http://192.168.100.133:8080');
  print('🖥️  Local: Use http://localhost:8080');
  print('Press Ctrl+C to stop');
}