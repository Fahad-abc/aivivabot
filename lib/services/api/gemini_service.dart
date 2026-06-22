import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/question_model.dart';
import '../../models/session_model.dart';
import '../../utils/constants.dart';
import '../api_service.dart';


class GeminiService {
  // Configured to route via backend proxy
  static String get _apiUrl => '${AppConstants.backendBaseUrl}/api/chat';
  static const String _apiKey = ''; // Ignored by backend proxy
  static const String _model = 'meta-llama/llama-3-8b-instruct:nitro';

  // ============================================================
  // GENERATE QUESTIONS - FROM AI BASED ON DOCUMENT
  // ============================================================

  Future<List<Question>> generateQuestions({
    required ExaminerMode mode,
    required int count,
    Map<String, dynamic>? fypMetadata,
    String language = 'english', // ✅ ADDED: Language parameter
  }) async {
    try {
      print('🟢 Generating $count questions from AI...');
      print('🟢 Language: $language');

      // Get uploaded document info from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final projectTitle = prefs.getString('documentName') ?? 'Final Year Project';
      final documentContent = prefs.getString('documentContent') ?? '';

      // Get technologies from fypMetadata or extract from document
      String technologies = '';
      if (fypMetadata != null && fypMetadata['technologies'] != null) {
        technologies = fypMetadata['technologies'].toString();
      }

      // Detect project domain from document content or title
      final projectDomain = _detectProjectDomain(projectTitle, documentContent);

      print('📄 Project Title: $projectTitle');
      print('🔍 Detected Domain: $projectDomain');
      print('📝 Document Content Length: ${documentContent.length} chars');

      // Language instruction
      String languageInstruction = '';
      if (language == 'roman_urdu') {
        languageInstruction = '''
LANGUAGE REQUIREMENT: You MUST write all questions in ROMAN URDU (Urdu written in English/Roman script).

IMPORTANT FOR ROMAN URDU:
- Use English alphabet to write Urdu sounds
- Examples: "Apne project mein Flutter kyun choose kiya?" instead of "Why did you choose Flutter?"
- Common Roman Urdu words: kyun (why), kya (what), kaise (how), batayein (explain), samjhayein (understand)
- Do NOT use Arabic/Persian script (like اردو)
- Use only English/Roman alphabet (a, b, c, ...)

Example questions in Roman Urdu:
- "Apke project ka main objective kya hai?"
- "Flutter mein state management kaise handle kiya?"
- "Database normalization kyun important hai?"
''';
      } else {
        languageInstruction = 'LANGUAGE REQUIREMENT: Write all questions in ENGLISH language only.';
      }

      // Skip AI call when document content is too short to be meaningful
      if (documentContent.isEmpty || documentContent.length <= 50) {
        print('⚠️ Document content too short (${documentContent.length} chars), using fallback questions');
        return _getDomainSpecificFallbackQuestions(projectDomain, count, language);
      }

      // If document content is available, use it
      String contentPreview = documentContent;
      if (contentPreview.length > 2000) {
        contentPreview = contentPreview.substring(0, 2000);
      }

      final String prompt = '''
You are a technical university viva examiner.

$languageInstruction

Generate $count technical questions based STRICTLY on the student's project document.

PROJECT TITLE: "$projectTitle"

PROJECT DOCUMENT CONTENT:
$contentPreview

TECHNOLOGIES MENTIONED: $technologies

IMPORTANT RULES:
1. Questions MUST be based ONLY on the document content above
2. DO NOT ask about technologies NOT mentioned in the document
3. Ask about specific features, architecture, or implementations from THEIR project
4. Questions should test understanding of THEIR unique project, not general knowledge

Return ONLY a JSON array. No other text. Format:
[{"text": "specific question based on document", "difficulty": "easy/medium/hard"}]
''';

      print('🟢 Sending prompt to OpenRouter...');

      final response = await ApiService.postRequest(
        body: {
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );

      print('🟢 Backend Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('🟢 AI Response: $content');

        final questions = _parseQuestionsFromResponse(content, mode);
        if (questions.isNotEmpty) {
          print('🟢 Successfully generated ${questions.length} questions');
          return questions.take(count).toList();
        }
      }

      // Fallback to domain-specific sample questions
      print('⚠️ Using fallback questions for domain: $projectDomain');
      return _getDomainSpecificFallbackQuestions(projectDomain, count, language);

    } catch (e) {
      print('❌ Generate questions error: $e');
      return _getFallbackQuestions(count, language);
    }
  }

  // ============================================================
  // EVALUATE ANSWER
  // ============================================================

  Future<AnswerEvaluation> evaluateAnswer({
    required Question question,
    required String userAnswer,
    String language = 'english', // ✅ ADDED: Language parameter
  }) async {
    try {
      print('🟢 Evaluating answer via backend...');
      print('🟢 Question: ${question.text}');
      print('🟢 User Answer: $userAnswer');
      print('🟢 Language: $language');

      // Language instruction for evaluation
      String languageInstruction = '';
      if (language == 'roman_urdu') {
        languageInstruction = '''
The question and answer may be in Roman Urdu. Evaluate based on technical accuracy regardless of language.
Feedback can be in simple English or Roman Urdu.
''';
      }

      final prompt = '''
You are a strict university viva examiner.

$languageInstruction

Question: "${question.text}"
Student Answer: "$userAnswer"
Ideal Answer: "${question.idealAnswer}"

Evaluate the answer based on:
- Technical accuracy
- Depth of understanding
- Clarity and structure

Scoring guidelines (0-10):
- 0-3: Completely wrong, irrelevant, or "I don't know"
- 4-6: Partially correct, missing key points
- 7-8: Good answer, mostly correct with minor gaps
- 9-10: Excellent, comprehensive, technically accurate

Return ONLY valid JSON. No other text.
{"score": number, "feedback": "short constructive feedback max 15 words"}
''';

      final response = await ApiService.postRequest(
        body: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 150,
        },
      );

      print('🟢 OpenRouter Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('🟢 AI Reply: $content');
        return _parseResponse(content);
      } else {
        print('❌ Backend Error: ${response.statusCode}');
        return _fallbackEvaluation(question, userAnswer);
      }
    } catch (e) {
      print('❌ Exception: $e');
      return _fallbackEvaluation(question, userAnswer);
    }
  }

  // ============================================================
  // GENERATE IDEAL ANSWER (For Review Screen)
  // ============================================================

  Future<String> generateIdealAnswer(
      String question, {
        String language = 'english', // ✅ ADDED: Language parameter
      }) async {
    try {
      print('🟢 Generating ideal answer for: $question');
      print('🟢 Language: $language');

      String languageInstruction = '';
      if (language == 'roman_urdu') {
        languageInstruction = '''
Write the answer in ROMAN URDU (Urdu written in English script).
Example: "Flutter ek cross-platform framework hai jo ek hi codebase se Android aur iOS apps banata hai."
Use simple, clear Roman Urdu.
''';
      } else {
        languageInstruction = 'Write the answer in ENGLISH language only.';
      }

      final prompt = '''
$languageInstruction

Provide a comprehensive, ideal answer for this university viva question:

Question: "$question"

Requirements:
- 2-3 sentences maximum
- Technically accurate
- Clear and concise
- Suitable for a university student

Return ONLY the answer text. No JSON, no extra formatting.
''';

      final response = await ApiService.postRequest(
        body: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 200,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['choices'][0]['message']['content'];
        return answer.trim();
      }
    } catch (e) {
      print('❌ Ideal answer error: $e');
    }
    return language == 'roman_urdu'
        ? 'Mukammal jawab available nahi. Apni project documentation ka mutalea karein.'
        : 'Ideal answer not available. Please refer to your project documentation.';
  }

  // ============================================================
  // GET HINT
  // ============================================================

  Future<String> getHint(Question question) async {
    try {
      final prompt = 'Give a very short hint (max 8 words) for: ${question.text}';

      final response = await ApiService.postRequest(
        body: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 50,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hint = data['choices'][0]['message']['content'];
        if (hint.isNotEmpty) {
          return hint.trim();
        }
      }
    } catch (e) {
      print('Hint error: $e');
    }
    return question.hints.isNotEmpty ? question.hints.first : 'Think about the core concept.';
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  String _detectProjectDomain(String title, String content) {
    final lowerTitle = title.toLowerCase();
    final lowerContent = content.toLowerCase();
    final fullText = '$lowerTitle $lowerContent';

    if (fullText.contains('blockchain') || fullText.contains('smart contract') || fullText.contains('crypto')) {
      return 'Blockchain';
    } else if (fullText.contains('flutter') || fullText.contains('mobile app') || fullText.contains('android') || fullText.contains('ios')) {
      return 'Flutter / Mobile Development';
    } else if (fullText.contains('machine learning') || fullText.contains('ai') || fullText.contains('neural network') || fullText.contains('deep learning')) {
      return 'Artificial Intelligence / Machine Learning';
    } else if (fullText.contains('web') || fullText.contains('react') || fullText.contains('angular') || fullText.contains('html')) {
      return 'Web Development';
    } else if (fullText.contains('database') || fullText.contains('sql') || fullText.contains('mongodb') || fullText.contains('firebase')) {
      return 'Database Management';
    } else if (fullText.contains('iot') || fullText.contains('sensor') || fullText.contains('raspberry')) {
      return 'Internet of Things (IoT)';
    } else if (fullText.contains('cloud') || fullText.contains('aws') || fullText.contains('azure')) {
      return 'Cloud Computing';
    } else if (fullText.contains('cybersecurity') || fullText.contains('security') || fullText.contains('encryption')) {
      return 'Cybersecurity';
    }
    return 'Computer Science';
  }

  List<Question> _parseQuestionsFromResponse(String responseText, ExaminerMode mode) {
    try {
      String clean = responseText.trim();
      if (clean.startsWith('```json')) {
        clean = clean.substring(7);
      }
      if (clean.startsWith('```')) {
        clean = clean.substring(3);
      }
      if (clean.endsWith('```')) {
        clean = clean.substring(0, clean.length - 3);
      }

      final jsonStart = clean.indexOf('[');
      final jsonEnd = clean.lastIndexOf(']') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = clean.substring(jsonStart, jsonEnd);
        final List<dynamic> data = jsonDecode(jsonString);

        int index = 0;
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final list = <Question>[];
        for (var item in data) {
          final questionText = (item['text'] ?? item['question'] ?? '').toString().trim();
          if (questionText.isEmpty) continue;

          list.add(Question(
            id: 'q_${nowMs}_${index++}',
            text: questionText,
            idealAnswer: (item['idealAnswer'] ?? item['answer'] ?? '').toString(),
            category: QuestionCategory.general,
            difficulty: _parseDifficulty(item['difficulty'] ?? 'medium'),
            type: QuestionType.openEnded,
            keywords: _extractKeywords(questionText),
            hints: [],
            commonMistakes: [],
            maxScore: 10,
            weightage: 1.0,
          ));
        }
        return list;
      }
    } catch (e) {
      print('Parse error in questions: $e');
    }
    return [];
  }

  List<String> _extractKeywords(String text) {
    final lowerText = text.toLowerCase();
    final commonKeywords = [
      'architecture', 'database', 'api', 'framework', 'algorithm',
      'security', 'performance', 'scalability', 'implementation',
      'design', 'testing', 'deployment', 'optimization'
    ];

    return commonKeywords.where((keyword) => lowerText.contains(keyword)).toList();
  }

  AnswerEvaluation _parseResponse(String text) {
    try {
      String clean = text.trim();
      if (clean.startsWith('```json')) {
        clean = clean.substring(7);
      }
      if (clean.startsWith('```')) {
        clean = clean.substring(3);
      }
      if (clean.endsWith('```')) {
        clean = clean.substring(0, clean.length - 3);
      }

      final jsonStart = clean.indexOf('{');
      final jsonEnd = clean.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = clean.substring(jsonStart, jsonEnd);
        final data = jsonDecode(jsonString);
        return AnswerEvaluation(
          score: (data['score'] ?? 5).toInt().clamp(0, 10),
          feedback: data['feedback'] ?? 'Good attempt!',
        );
      }
    } catch (e) {
      print('Parse error: $e');
    }
    return AnswerEvaluation(score: 5, feedback: 'Answer recorded!');
  }

  AnswerEvaluation _fallbackEvaluation(Question question, String userAnswer) {
    int score = 5;

    for (String keyword in question.keywords) {
      if (userAnswer.toLowerCase().contains(keyword.toLowerCase())) {
        score++;
      }
    }

    if (userAnswer.length > 50) score++;
    if (userAnswer.length > 100) score++;

    score = score.clamp(0, 10);

    String feedback;
    if (score >= 8) {
      feedback = 'Excellent! Great technical understanding.';
    } else if (score >= 6) {
      feedback = 'Good answer! Add more technical depth.';
    } else if (score >= 4) {
      feedback = 'Good attempt. Review the key concepts.';
    } else {
      feedback = 'Review the fundamentals of this topic.';
    }

    return AnswerEvaluation(
      score: score,
      feedback: feedback,
    );
  }

  List<Question> _getDomainSpecificFallbackQuestions(String domain, int count, String language) {
    List<String> questions = [];

    if (language == 'roman_urdu') {
      // Roman Urdu fallback questions
      switch (domain) {
        case 'Blockchain':
          questions = [
            'Blockchain kya hai? Iske main features kya hain?',
            'Smart contract kya hota hai? Ye kaise kaam karta hai?',
            'Proof of Work aur Proof of Stake mein kya farq hai?',
            'Blockchain mein data immutable kyun hota hai?',
            '51% attack kya hai? Isse kaise bacha ja sakta hai?',
          ];
          break;
        case 'Flutter / Mobile Development':
          questions = [
            'Flutter kya hai? Isme StatefulWidget aur StatelessWidget mein kya farq hai?',
            'Flutter mein cross-platform development kaise possible hai?',
            'Hot reload feature Flutter mein kya faida deta hai?',
            'Flutter ki performance React Native se behtar kyun hai?',
            'Widget lifecycle Flutter mein kya hota hai?',
          ];
          break;
        case 'Internet of Things (IoT)':
          questions = [
            'IoT system ki architecture kya hai? Iske key components kya hain?',
            'IoT network mein sensors kaise communicate karte hain?',
            'IoT mein konse communication protocols use hote hain?',
            'IoT devices mein data security kaise handle ki jati hai?',
            'IoT mein scalability aur power management ke challenges kya hain?',
          ];
          break;
        default:
          questions = [
            'Apke project ka main objective kya hai?',
            'Project mein aapne konsi technologies use ki hain aur kyun?',
            'Project ki architecture explain karein.',
            'Project mein aapne security kaise handle ki?',
            'Project ko future mein kaise scale karenge?',
          ];
      }
    } else {
      // English fallback questions
      switch (domain) {
        case 'Blockchain':
          questions = [
            'What is a smart contract and how does it work?',
            'Explain the difference between Proof of Work and Proof of Stake.',
            'What is a 51% attack and how can it be prevented?',
            'How does blockchain ensure data immutability?',
            'What are the main challenges in blockchain scalability?',
          ];
          break;
        case 'Artificial Intelligence / Machine Learning':
          questions = [
            'Explain the difference between supervised and unsupervised learning.',
            'What is overfitting and how do you prevent it?',
            'How does a neural network learn from data?',
            'What evaluation metrics would you use for classification problems?',
            'Explain the bias-variance tradeoff.',
          ];
          break;
        case 'Flutter / Mobile Development':
          questions = [
            'What is the difference between StatefulWidget and StatelessWidget?',
            'How does Flutter handle platform-specific code?',
            'Explain the widget lifecycle in Flutter.',
            'What are the advantages of using Flutter over React Native?',
            'How does Flutter achieve high performance?',
          ];
          break;
        case 'Internet of Things (IoT)':
          questions = [
            'Explain the architecture of an IoT system and its key components.',
            'How do sensors communicate data in an IoT network?',
            'What communication protocols are commonly used in IoT?',
            'How is data security handled in IoT devices?',
            'What are the main challenges in IoT scalability and power management?',
          ];
          break;
        case 'Web Development':
          questions = [
            'Explain the difference between client-side and server-side rendering.',
            'What is RESTful API design and why is it important?',
            'How do you optimize web application performance?',
            'Explain the concept of responsive web design.',
            'What security measures do you implement in web applications?',
          ];
          break;
        case 'Database Management':
          questions = [
            'Explain the difference between SQL and NoSQL databases.',
            'What is database normalization and why is it important?',
            'How do you optimize database query performance?',
            'Explain ACID properties in database transactions.',
            'What strategies do you use for database backup and recovery?',
          ];
          break;
        case 'Cloud Computing':
          questions = [
            'Explain the difference between IaaS, PaaS, and SaaS.',
            'What are the advantages of cloud-based deployment?',
            'How do you ensure data security in the cloud?',
            'Explain auto-scaling and load balancing in cloud architecture.',
            'What is serverless computing and when would you use it?',
          ];
          break;
        case 'Cybersecurity':
          questions = [
            'Explain the CIA triad in information security.',
            'What are common types of cyber attacks and how do you prevent them?',
            'How does encryption protect data in transit and at rest?',
            'Explain the concept of zero-trust security model.',
            'What is penetration testing and why is it important?',
          ];
          break;
        default:
          questions = [
            'Explain the core architecture of your project.',
            'What were the main technical challenges you faced?',
            'How did you ensure data security in your application?',
            'What technologies did you use and why?',
            'How would you scale your project for production use?',
          ];
      }
    }

    return questions.take(count).map((text) {
      return Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        idealAnswer: '',
        category: QuestionCategory.general,
        difficulty: QuestionDifficulty.medium,
        type: QuestionType.openEnded,
        keywords: [],
        hints: [],
        commonMistakes: [],
        maxScore: 10,
        weightage: 1.0,
      );
    }).toList();
  }

  List<Question> _getFallbackQuestions(int count, String language) {
    return _getDomainSpecificFallbackQuestions('Computer Science', count, language);
  }

  QuestionDifficulty _parseDifficulty(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy': return QuestionDifficulty.easy;
      case 'hard': return QuestionDifficulty.hard;
      case 'expert': return QuestionDifficulty.expert;
      default: return QuestionDifficulty.medium;
    }
  }
}

class AnswerEvaluation {
  final int score;
  final String feedback;

  AnswerEvaluation({
    required this.score,
    required this.feedback,
  });
}