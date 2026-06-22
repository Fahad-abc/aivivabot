import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

class PdfTextExtractor {
  static Future<String> extractText(Uint8List bytes) async {
    try {
      // Load the PDF document
      final sf.PdfDocument pdf = sf.PdfDocument(inputBytes: bytes);
      final textBuffer = StringBuffer();

      // Create the text extractor
      final sf.PdfTextExtractor extractor = sf.PdfTextExtractor(pdf);

      print('📄 PDF Pages: ${pdf.pages.count}');

      for (int i = 0; i < pdf.pages.count; i++) {
        // Extract text from the specific page
        final String extracted = extractor.extractText(startPageIndex: i, endPageIndex: i);
        if (extracted.trim().isNotEmpty) {
          textBuffer.writeln('--- Page ${i + 1} ---');
          textBuffer.writeln(extracted);
          textBuffer.writeln();
        }
      }

      pdf.dispose();
      final fullText = textBuffer.toString();

      print('📄 Extracted: ${fullText.length} chars');
      return fullText;

    } catch (e) {
      print('❌ PDF Error: $e');
      return '';
    }
  }
}
