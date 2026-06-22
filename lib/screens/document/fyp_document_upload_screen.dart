import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aivivabot/utils/pdf_text_extractor.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// FYP DOCUMENT UPLOAD SCREEN - Beautiful Interface
// ============================================================

class FypDocumentUploadScreen extends StatefulWidget {
  const FypDocumentUploadScreen({super.key});

  @override
  State<FypDocumentUploadScreen> createState() => _FypDocumentUploadScreenState();
}

class _FypDocumentUploadScreenState extends State<FypDocumentUploadScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  File? _selectedFile;
  String? _fileName;
  String? _fileSize;
  bool _isUploading = false;
  bool _isUploaded = false;
  Uint8List? _fileBytes;
  String _extractedText = '';

  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _techStackController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();

  bool _useDocument = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkExistingDocument();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  Future<void> _checkExistingDocument() async {
    final prefs = await SharedPreferences.getInstance();
    final isUploaded = prefs.getBool('isDocumentUploaded') ?? false;
    final savedName = prefs.getString('documentName');
    final savedContent = prefs.getString('documentContent');

    if (isUploaded && savedName != null) {
      setState(() {
        _fileName = savedName;
        _isUploaded = true;
        if (savedContent != null) {
          _extractedText = savedContent;
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _projectTitleController.dispose();
    _techStackController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                const Color(0xFF0A0E27),
                const Color(0xFF1A1F3E),
                const Color(0xFF16213E),
              ]
                  : [
                const Color(0xFFF5F7FF),
                const Color(0xFFE8ECFF),
                const Color(0xFFE0E7FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildInfoCard(isDark),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildToggleSection(isDark),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _useDocument
                              ? _buildDocumentUploadSection(isDark)
                              : _buildManualEntrySection(isDark),
                        ),
                        const SizedBox(height: 32),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildActionButton(isDark),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => AppRoutes.goBack(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FYP Document',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  'Upload or enter your project details',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A5CFF),
            Color(0xFF7000FF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A5CFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Powered Questions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload your FYP document to get custom questions from AI',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF2A5CFF).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useDocument = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _useDocument
                      ? const Color(0xFF2A5CFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: _useDocument ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          color: _useDocument ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _useDocument = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !_useDocument
                      ? const Color(0xFF2A5CFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_note,
                        color: !_useDocument ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Manual Entry',
                        style: TextStyle(
                          color: !_useDocument ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection(bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1F3E).withOpacity(0.8)
                : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFF2A5CFF).withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0A0E27).withOpacity(0.5)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (_fileName != null)
                          ? Colors.green
                          : (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[300]!),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_isUploading)
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A5CFF)),
                          ),
                        )
                      else if (_fileName != null)
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 45,
                          ),
                        )
                      else
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A5CFF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload,
                            color: Color(0xFF2A5CFF),
                            size: 40,
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (_fileName != null) ...[
                        Text(
                          _fileName!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0A0E27),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fileSize ?? 'Previously uploaded',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        if (_extractedText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_extractedText.length} characters extracted',
                              style: const TextStyle(color: Colors.green, fontSize: 12),
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          'Tap to upload PDF',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF0A0E27),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supported: PDF (Max 10MB)',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A5CFF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Browse Files',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_fileName != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFileActionButton(
                        icon: Icons.clear,
                        label: 'Remove',
                        color: Colors.red,
                        onTap: _removeFile,
                        isDark: isDark,
                      ),
                      _buildFileActionButton(
                        icon: Icons.refresh,
                        label: 'Change',
                        color: const Color(0xFF2A5CFF),
                        onTap: _pickFile,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? Colors.amber : Colors.blue).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: isDark ? Colors.amber[300] : Colors.blue[700],
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Upload your proposal, report, or presentation. AI will analyze and generate custom questions based on your project.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntrySection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF2A5CFF).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildManualField(
            controller: _projectTitleController,
            label: 'Project Title',
            hint: 'e.g., AI VivaBot - Voice Assistant',
            icon: Icons.title,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _buildManualField(
            controller: _techStackController,
            label: 'Technologies Used',
            hint: 'e.g., Flutter, Firebase, Blockchain',
            icon: Icons.code,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _buildManualField(
            controller: _featuresController,
            label: 'Key Features',
            hint: 'Describe main features of your project',
            icon: Icons.format_list_bulleted,
            maxLines: 3,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildManualField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF2A5CFF)),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0A0E27).withOpacity(0.6)
                : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2A5CFF), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isDark) {
    final isEnabled = _useDocument ? _fileName != null : true;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isEnabled && !_isUploading ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A5CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isUploading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          _useDocument ? 'Process Document' : 'Save & Continue',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ✅ FIXED: _pickFile with better extraction
  // ============================================================
  Future<void> _pickFile() async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        final file = result.files.single;
        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }

        setState(() {
          _fileName = file.name;
          _fileSize = _formatFileSize(file.size);
          _fileBytes = bytes;
          _isUploading = true;
        });

        if (bytes != null) {
          await _extractTextFromPDF(bytes);
        } else {
          throw Exception("Could not read file data");
        }

        setState(() {
          _isUploading = false;
        });

        _showSnackBar('PDF uploaded and text extracted successfully!');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error: Unable to read file. Try Manual Entry instead.');
    }
  }

  // ============================================================
  // ✅ FIXED: _extractTextFromPDF with better extraction
  // ============================================================
  Future<void> _extractTextFromPDF(Uint8List bytes) async {
    try {
      String extractedText = await PdfTextExtractor.extractText(bytes);

      // ✅ ADD DEBUG PRINTS
      print('📄 ===== PDF EXTRACTION =====');
      print('📄 Extracted Length: ${extractedText.length}');
      print('📄 First 500 chars:');
      print('📄 ${extractedText.substring(0, extractedText.length > 500 ? 500 : extractedText.length)}');
      print('📄 ============================');

      if (extractedText.isEmpty) {
        extractedText = 'Project: ${_fileName ?? "Unknown"}';
      }

      // ✅ REMOVE CHARACTER LIMIT - Save full text
      // if (extractedText.length > 3000) {
      //   extractedText = extractedText.substring(0, 3000);
      // }

      setState(() {
        _extractedText = extractedText;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('documentContent', extractedText);
      await prefs.setString('documentName', _fileName ?? '');
      await prefs.setBool('isDocumentUploaded', true);

      print('✅ Document saved to SharedPreferences');
      print('📄 Saved Length: ${extractedText.length}');

    } catch (e) {
      print('❌ PDF Extraction Error: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('documentContent', 'Project file: ${_fileName ?? "Unknown"}');
      await prefs.setString('documentName', _fileName ?? '');
      await prefs.setBool('isDocumentUploaded', true);

      setState(() {
        _extractedText = 'Project: ${_fileName ?? "Unknown"}';
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _removeFile() {
    setState(() {
      _fileName = null;
      _fileSize = null;
      _fileBytes = null;
      _extractedText = '';
    });

    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('documentContent');
      prefs.remove('documentName');
      prefs.remove('isDocumentUploaded');
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isUploading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDocumentUploaded', true);

    if (_useDocument) {
      if (_fileName != null) {
        await prefs.setString('documentName', _fileName!);
      }
      if (_extractedText.isEmpty) {
        await prefs.setString('documentContent', 'Project: ${_fileName ?? "FYP Project"}');
      }
    } else {
      final manualContent = '''
Project Title: ${_projectTitleController.text}
Technologies Used: ${_techStackController.text}
Key Features: ${_featuresController.text}
''';
      await prefs.setString('documentContent', manualContent);
      await prefs.setString('documentName', _projectTitleController.text.isEmpty ? 'Manual Entry' : _projectTitleController.text);
    }

    setState(() {
      _isUploading = false;
      _isUploaded = true;
    });

    _showSnackBar(_useDocument ? 'Document processed successfully!' : 'Project details saved!');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AppRoutes.goBack(context);
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}