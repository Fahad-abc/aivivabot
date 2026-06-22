import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../services/notes_service.dart';
import '../../services/pdf_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  String _documentContent = '';
  String _notes = '';
  bool _isLoading = false;
  bool _hasNotes = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _loadDocument();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _documentContent = prefs.getString('documentContent') ?? '';
    });
  }

  Future<void> _generateNotes() async {
    if (_documentContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a document first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _notes = '';
      _hasNotes = false;
    });

    // Beautiful Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: Color(0xFF2A5CFF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Creating Study Notes...',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A5CFF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI is analyzing your document',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: _animationController.value,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFF2A5CFF),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This may take 30-60 seconds...',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    _animationController.repeat();

    try {
      final notes = await NotesService.generateNotes(documentContent: _documentContent);
      _animationController.stop();

      if (mounted) {
        Navigator.pop(context);

        if (notes == null || notes.isEmpty || notes.startsWith('Error:')) {
          setState(() {
            _isLoading = false;
            _errorMessage = notes?.startsWith('Error:') == true ? notes : 'Failed to generate notes. Please try again.';
            _hasNotes = false;
            _notes = '';
          });
        } else {
          setState(() {
            _notes = notes;
            _isLoading = false;
            _hasNotes = true;
            _errorMessage = '';
          });
        }
      }
    } catch (e) {
      _animationController.stop();
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
          _hasNotes = false;
          _notes = '';
        });
      }
    }
  }

  Future<void> _downloadPDF() async {
    if (_notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No notes to download. Generate notes first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Header with Logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    gradient: const pw.LinearGradient(
                      colors: [PdfColors.blue800, PdfColors.blue600],
                    ),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'AV',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'AI VivaBot',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      'AI-Powered Study Notes',
                      style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 2, color: PdfColors.blue300),
            pw.SizedBox(height: 20),

            // Main Title
            pw.Center(
              child: pw.Text(
                '📚 COMPLETE STUDY NOTES',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey500),
              ),
            ),
            pw.SizedBox(height: 30),

            // Notes Content
            ..._convertNotesToPdf(),

            // Footer
            pw.SizedBox(height: 30),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'AI VivaBot - Your AI-Powered Study Assistant',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
                pw.Text(
                  'Page 1',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
              ],
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        PdfService.downloadPDF(pdfBytes, 'study_notes_${DateTime.now().millisecondsSinceEpoch}.pdf');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF Downloaded!'), backgroundColor: Colors.green),
          );
        }
      } else {
        final filePath = await PdfService.savePDFMobile(pdfBytes, 'study_notes_${DateTime.now().millisecondsSinceEpoch}.pdf');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF saved!'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Share',
                onPressed: () => PdfService.shareReport(filePath),
                textColor: Colors.white,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<pw.Widget> _convertNotesToPdf() {
    if (_notes.isEmpty) {
      return [
        pw.Center(
          child: pw.Text(
            'No notes available. Please generate notes first.',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.red),
          ),
        ),
      ];
    }

    final lines = _notes.split('\n');
    final widgets = <pw.Widget>[];

    for (var line in lines) {
      // Main Heading (# Title)
      if (line.trim().startsWith('# ') && !line.trim().startsWith('##')) {
        String title = line.trim().substring(2);
        widgets.add(pw.SizedBox(height: 20));
        widgets.add(pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(title,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        ));
        widgets.add(pw.SizedBox(height: 15));
      }
      // Sub Heading (## Title)
      else if (line.trim().startsWith('## ') && !line.trim().startsWith('###')) {
        String title = line.trim().substring(3);
        widgets.add(pw.SizedBox(height: 15));
        widgets.add(pw.Text(title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)));
        widgets.add(pw.SizedBox(height: 8));
        widgets.add(pw.Divider(thickness: 1, color: PdfColors.blue200));
        widgets.add(pw.SizedBox(height: 8));
      }
      // Sub-sub Heading (### Title)
      else if (line.trim().startsWith('### ') && !line.trim().startsWith('####')) {
        String title = line.trim().substring(4);
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(pw.Text(title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)));
        widgets.add(pw.SizedBox(height: 6));
      }
      // Bold text (**text**)
      else if (line.contains('**') && !line.contains('```')) {
        String text = line.replaceAll('**', '');
        widgets.add(pw.Text(text,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)));
        widgets.add(pw.SizedBox(height: 4));
      }
      // Key Takeaways
      else if (line.contains('Key Takeaways') || line.contains('Key Takeaways:')) {
        widgets.add(pw.SizedBox(height: 10));
        String content = line;
        widgets.add(pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.yellow50,
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: PdfColors.yellow200),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('⭐ ', style: pw.TextStyle(fontSize: 14)),
              pw.Expanded(
                child: pw.Text(content,
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
              ),
            ],
          ),
        ));
        widgets.add(pw.SizedBox(height: 8));
      }
      // Numbered list (1., 2., etc.)
      else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        String number = line.trim().split('.')[0];
        String text = line.trim().substring(line.trim().indexOf('.') + 2);
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$number. ',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue600)),
              pw.Expanded(
                child: pw.Text(text, style: pw.TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ));
        widgets.add(pw.SizedBox(height: 4));
      }
      // Bullet points (- or •)
      else if (line.trim().startsWith('- ') || line.trim().startsWith('• ')) {
        String text = line.trim().substring(2);
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('▹ ', style: pw.TextStyle(fontSize: 11, color: PdfColors.blue600)),
              pw.Expanded(child: pw.Text(text, style: pw.TextStyle(fontSize: 11))),
            ],
          ),
        ));
        widgets.add(pw.SizedBox(height: 2));
      }
      // Dependency/Code line
      else if (line.contains('pubspec.yaml') || line.contains('dependency') || line.contains('import ')) {
        widgets.add(pw.Container(
          padding: const pw.EdgeInsets.all(8),
          margin: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Text(line,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
        ));
      }
      // Code blocks
      else if (line.trim().startsWith('```')) {
        // Skip code block markers
      }
      // Empty line
      else if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 6));
      }
      // Regular text - property description with colon
      else if (line.contains(':') && line.length < 100 && !line.contains('http')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10),
          child: pw.Text(line,
              style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
        ));
        widgets.add(pw.SizedBox(height: 2));
      }
      // Regular text
      else {
        widgets.add(pw.Text(line, style: pw.TextStyle(fontSize: 11, height: 1.5, color: PdfColors.grey800)));
        widgets.add(pw.SizedBox(height: 2));
      }
    }

    widgets.add(pw.SizedBox(height: 30));
    return widgets;
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Study Notes Generator',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0A0E27),
                        ),
                      ),
                    ),
                    if (_hasNotes)
                      IconButton(
                        onPressed: _downloadPDF,
                        icon: const Icon(Icons.download, color: Color(0xFF2A5CFF)),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_hasNotes
                    ? _buildNotesView(isDark)
                    : (_errorMessage.isNotEmpty
                    ? _buildErrorView(isDark)
                    : _buildEmptyView(isDark))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Generate Notes',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A5CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.note_alt, color: Colors.white, size: 55),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Generate AI Study Notes',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0A0E27),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI will analyze your document and create\ncomprehensive study notes with definitions,\nexamples, and key takeaways.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 220,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2A5CFF).withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _generateNotes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                                SizedBox(width: 12),
                                Text(
                                  'Generate Notes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_documentContent.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'No document found. Please upload a document first.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesView(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasNotes = false;
                      _notes = '';
                      _errorMessage = '';
                    });
                    _generateNotes();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerate'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2A5CFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _downloadPDF,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A5CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                _notes.isEmpty ? 'No notes available. Click Generate Notes to create study notes.' : _notes,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}