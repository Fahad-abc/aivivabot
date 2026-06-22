import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'download_helper.dart' as dh;

class PdfService {
  // ============================================================
  // FOR WEB - Returns bytes directly
  // ============================================================
  static Future<Uint8List> generateQuizReportBytes({
    required String userName,
    required String quizType,
    required int totalScore,
    required int maxScore,
    required int percentage,
    required List<Map<String, dynamic>> results,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildPdfContent(
          userName, quizType, totalScore, maxScore, percentage, results,
        ),
      ),
    );

    return await pdf.save();
  }

  // ============================================================
  // FOR MOBILE/DESKTOP - Returns file path
  // ============================================================
  static Future<String> generateQuizReport({
    required String userName,
    required String quizType,
    required int totalScore,
    required int maxScore,
    required int percentage,
    required List<Map<String, dynamic>> results,
    String? appLogo,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildPdfContent(
          userName, quizType, totalScore, maxScore, percentage, results,
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/quiz_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  // ============================================================
  // SHARE REPORT (Mobile/Desktop only)
  // ============================================================
  static Future<void> shareReport(String filePath) async {
    if (!kIsWeb) {
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: 'My Quiz Report from AI VivaBot - Check my performance!',
      );
    }
  }

  // ============================================================
  // WEB PDF DOWNLOAD
  // ============================================================
  static void downloadPDF(Uint8List bytes, String fileName) {
    dh.downloadFile(bytes, fileName);
  }

  // ============================================================
  // MOBILE PDF SAVE
  // ============================================================
  static Future<String> savePDFMobile(Uint8List bytes, String fileName) async {
    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  // ============================================================
  // PDF CONTENT BUILDER (Common for all platforms)
  // ============================================================
  static List<pw.Widget> _buildPdfContent(
      String userName,
      String quizType,
      int totalScore,
      int maxScore,
      int percentage,
      List<Map<String, dynamic>> results,
      ) {
    return [
      pw.Header(
        level: 0,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildTextLogo(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'AI VivaBot',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  'AI-Powered Quiz Report',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      pw.Center(
        child: pw.Text(
          'QUIZ COMPLETION REPORT',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Center(
        child: pw.Text(
          'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      ),
      pw.Divider(),
      pw.SizedBox(height: 20),
      pw.Container(
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.blue800),
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Student Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(userName),
                  pw.SizedBox(height: 10),
                  pw.Text('Quiz Type:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(quizType == 'short' ? '📝 Short Questions' : '📋 Multiple Choice'),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Score:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('$totalScore / $maxScore',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Percentage:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('$percentage%',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      pw.Center(
        child: pw.Container(
          width: 100,
          height: 100,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: percentage >= 70
                ? PdfColors.green600
                : (percentage >= 50 ? PdfColors.orange600 : PdfColors.red600),
          ),
          child: pw.Center(
            child: pw.Text(
              '$percentage%',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
      ),
      pw.SizedBox(height: 20),
      pw.Center(
        child: pw.Text(
          _getGradeMessage(percentage),
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: percentage >= 70
                ? PdfColors.green600
                : (percentage >= 50 ? PdfColors.orange600 : PdfColors.red600),
          ),
        ),
      ),
      pw.Divider(),
      pw.SizedBox(height: 20),
      pw.Text(
        'Question-wise Analysis',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
      ),
      pw.SizedBox(height: 10),
      ...results.asMap().entries.map((entry) {
        final index = entry.key;
        final result = entry.value;
        final score = result['score'] as int;
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 15),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Q${index + 1}. ${result['question']}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  pw.Text(
                    '$score/10',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: score >= 7 ? PdfColors.green600 : PdfColors.red600,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Your Answer: ${result['userAnswer']}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              if (result.containsKey('idealAnswer'))
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text('Ideal Answer: ${result['idealAnswer']}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.blue700)),
                ),
              pw.SizedBox(height: 4),
              pw.Text('Feedback: ${result['feedback']}',
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
            ],
          ),
        );
      }),
      pw.SizedBox(height: 20),
      pw.Divider(),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(height: 10),
          pw.Text(
            'AI VivaBot - Your AI-Powered Viva Assistant',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '© ${DateTime.now().year} AI VivaBot. All rights reserved.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    ];
  }

  static pw.Widget _buildTextLogo() {
    return pw.Container(
      width: 50,
      height: 50,
      decoration: pw.BoxDecoration(
        color: PdfColors.blue800,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Center(
        child: pw.Text(
          'AV',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ),
    );
  }

  static String _getGradeMessage(int percentage) {
    if (percentage >= 90) return '🌟 Excellent! Outstanding performance!';
    if (percentage >= 80) return '👍 Very Good! Keep it up!';
    if (percentage >= 70) return '✅ Good! Well done!';
    if (percentage >= 60) return '📚 Satisfactory. Need improvement.';
    if (percentage >= 50) return '⚠️ Fair. Study more!';
    return '❌ Poor performance. Review thoroughly!';
  }
}