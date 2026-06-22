import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';

class QuizTypeSelectionScreen extends StatefulWidget {
  const QuizTypeSelectionScreen({super.key});

  @override
  State<QuizTypeSelectionScreen> createState() => _QuizTypeSelectionScreenState();
}

class _QuizTypeSelectionScreenState extends State<QuizTypeSelectionScreen> {
  String _selectedType = 'short'; // 'short' or 'mcq'
  int _questionCount = 10;
  final List<int> _countOptions = [5, 10, 15, 20];
  bool _isLoading = false;
  String? _documentContent;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final doc = prefs.getString('documentContent') ?? '';

    print('📄 ===== QUIZ TYPE SELECTION =====');
    print('📄 Document Length: ${doc.length}');
    print('📄 First 300 chars: ${doc.substring(0, doc.length > 300 ? 300 : doc.length)}');
    print('📄 ================================');

    setState(() {
      _documentContent = doc;
      _userName = prefs.getString('userName') ?? 'Student';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3E)]
                : [const Color(0xFFF5F7FF), const Color(0xFFE8ECFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isDark),
                const SizedBox(height: 24),

                // Document Status
                _buildDocumentStatus(isDark),
                const SizedBox(height: 32),

                // Welcome Text
                _buildWelcomeText(isDark),
                const SizedBox(height: 24),

                // Quiz Type Selection
                _buildQuizTypeSection(isDark),
                const SizedBox(height: 32),

                // Question Count Selection
                _buildQuestionCountSection(isDark),
                const SizedBox(height: 32),

                // Info Box
                _buildInfoBox(isDark),
                const SizedBox(height: 24),

                // Start Button
                _buildStartButton(isDark),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Theory Quiz',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2A5CFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Beta',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2A5CFF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentStatus(bool isDark) {
    final bool hasDocument = _documentContent != null && _documentContent!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: hasDocument
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDocument
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDocument ? Icons.check_circle : Icons.warning_amber,
            color: hasDocument ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasDocument
                  ? '✓ Document loaded! Quiz will be based on your uploaded FYP document.'
                  : '⚠️ No document found. Please upload a document first from Document Upload screen.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $_userName! 👋',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Test your knowledge with AI-generated questions',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizTypeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Quiz Type',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTypeCard(
                title: '📝 Short Questions',
                subtitle: 'Write detailed answers',
                description: 'AI evaluates your descriptive answers',
                isSelected: _selectedType == 'short',
                onTap: () => setState(() => _selectedType = 'short'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeCard(
                title: '📋 Multiple Choice',
                subtitle: 'Select from options',
                description: 'Choose correct answer from 4 options',
                isSelected: _selectedType == 'mcq',
                onTap: () => setState(() => _selectedType = 'mcq'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2A5CFF)
              : (isDark ? const Color(0xFF1A1F3E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF2A5CFF).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0A0E27)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white60 : (isDark ? Colors.grey[500] : Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCountSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Questions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: _countOptions.map((count) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildCountButton(
                count: count,
                isSelected: _questionCount == count,
                onTap: () => setState(() => _questionCount = count),
                isDark: isDark,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCountButton({
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2A5CFF)
              : (isDark ? const Color(0xFF1A1F3E) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
          ),
        ),
        child: Center(
          child: Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0A0E27)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A5CFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2A5CFF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedType == 'short'
                  ? '📝 Short Questions: Write detailed answers. AI will evaluate and provide feedback with scores.'
                  : '📋 Multiple Choice: Each question has 4 options with one correct answer. Instant scoring after each question.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2A5CFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(bool isDark) {
    final bool hasDocument = _documentContent != null && _documentContent!.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasDocument ? _startQuiz : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A5CFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          'Start Quiz',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _startQuiz() async {
    if (_documentContent == null || _documentContent!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a document first from Document Upload screen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ ADDED: Print document info before starting quiz
    print('📄 ===== STARTING QUIZ =====');
    print('📄 Document Length: ${_documentContent!.length}');
    print('📄 First 200 chars: ${_documentContent!.substring(0, _documentContent!.length > 200 ? 200 : _documentContent!.length)}');
    print('📄 Quiz Type: $_selectedType');
    print('📄 Question Count: $_questionCount');
    print('📄 ==========================');

    setState(() {
      _isLoading = true;
    });

    // Navigate to Quiz Screen using AppRoutes
    await AppRoutes.navigateToQuiz(
      context,
      quizType: _selectedType,
      questionCount: _questionCount,
      documentContent: _documentContent!,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}