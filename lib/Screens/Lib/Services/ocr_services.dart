import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<Map<String, String>> extractVatData(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final fullText = recognizedText.text;

    // Dubai VAT patterns - English + Arabic invoices
    final trnRegex = RegExp(r'(TRN|Tax Registration Number)[\s:]*([0-9]{15})', caseSensitive: false);
    final invoiceRegex = RegExp(r'(Invoice No|Inv No|Tax Invoice)[\s:]*([A-Za-z0-9-\/]+)', caseSensitive: false);
    final vatRegex = RegExp(r'VAT\s*Amount[\s:]*AED?\s*([0-9]+\.?[0-9]*)', caseSensitive: false);
    final totalRegex = RegExp(r'(Total Amount|Grand Total|Net Payable)[\s:]*AED?\s*([0-9]+\.?[0-9]*)', caseSensitive: false);
    final dateRegex = RegExp(r'([0-9]{1,2}[\/\-][0-9]{1,2}[\/\-][0-9]{2,4})');

    String trn = trnRegex.firstMatch(fullText)?.group(2) ?? '';
    String invoiceNo = invoiceRegex.firstMatch(fullText)?.group(2) ?? '';
    String vat = vatRegex.firstMatch(fullText)?.group(1) ?? '';
    String total = totalRegex.firstMatch(fullText)?.group(2) ?? '';
    String date = dateRegex.firstMatch(fullText)?.group(1) ?? '';

    return {
      'trn': trn,
      'invoiceNo': invoiceNo,
      'vat': vat,
      'total': total,
      'date': date,
      'raw': fullText,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
