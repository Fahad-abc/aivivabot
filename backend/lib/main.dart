import 'dart:convert';
import 'dart:io' show Platform;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';

Future<void> runServer() async {
  final env = DotEnv()..load();
  final String _apiKey = Platform.environment['OPENROUTER_API_KEY'] ?? env['OPENROUTER_API_KEY'] ?? '';

  if (_apiKey.isEmpty) {
    print('❌ ERROR: OPENROUTER_API_KEY not set. Set it in environment or .env file.');
    return;
  }

  final app = Router();

  // GET request - Health check
  app.get('/', (Request request) {
    return Response.ok('AI VivaBot Server is Running!');
  });

  // POST request - Passthrough proxy to OpenRouter
  app.post('/api/chat', (Request request) async {
    try {
      final body = await request.readAsString();
      print('📥 Forwarding request to OpenRouter...');

      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('🟢 OpenRouter Status: ${response.statusCode}');

      return Response.ok(
        response.body,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('❌ Error: $e');
      return Response.badRequest(
        body: jsonEncode({'error': 'Server error: $e', 'status': 'error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // CORS middleware
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(app.call);

  // Bind to 0.0.0.0 so it's reachable from emulators and physical devices
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('✅ Server running on http://${server.address.host}:${server.port}');
  print('📡 POST endpoint: http://localhost:8080/api/chat');
  print('🔄 Proxying requests to: $_openRouterUrl');
}
