import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'menubar.dart';   // 🔥 add menu drawer

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  Future<String> generateResponse(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent');

    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
          'No response';
    } else {
      throw Exception(
          'Failed to call Gemini API: ${response.statusCode} - ${response.body}');
    }
  }
}

class ExpertHelpScreen extends StatefulWidget {
  const ExpertHelpScreen({super.key});

  @override
  _ExpertHelpScreenState createState() => _ExpertHelpScreenState();
}

class _ExpertHelpScreenState extends State<ExpertHelpScreen> {
  final TextEditingController _controller = TextEditingController();
  late GeminiService _geminiService;
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService('API KEY');
  }

  void _sendQuery() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final res = await _geminiService.generateResponse(prompt);
      setState(() {
        _response = res;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⭐ RIGHT-SIDE MENU
      endDrawer: AppMenuDrawer(
        onNavigate: (dest) {
          Navigator.pop(context); // close drawer first

          switch (dest) {
            case MenuDestination.home:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case MenuDestination.schemes:
              Navigator.pushReplacementNamed(context, '/schemes');
              break;
            case MenuDestination.practices:
              Navigator.pushReplacementNamed(context, '/practices');
              break;
            case MenuDestination.expertHelp:
              break; // already here
            case MenuDestination.profile:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            case MenuDestination.logout:
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
      ),

      appBar: AppBar(
        title: const Text('AI Expert Helper'),
        actions: [
          // ⭐ Right-side menu button
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open menu',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ask your farming questions here...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendQuery,
                ),
              ),
              onSubmitted: (_) => !_isLoading ? _sendQuery() : null,
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const CircularProgressIndicator()
            else if (_response.isNotEmpty)
              Expanded(
                child: Markdown(
                  data: _response,
                  styleSheet: MarkdownStyleSheet.fromTheme(
                    Theme.of(context),
                  ).copyWith(
                    p: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 16),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'Enter a question to get expert farming advice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
