import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<void> exportToTally(Map<String, String> data) async {
    final xml = '''
<TALLYMESSAGE>
  <VOUCHER>
    <DATE>${data['date']}</DATE>
    <PARTYTRN>${data['trn']}</PARTYTRN>
    <INVOICENO>${data['invoiceNo']}</INVOICENO>
    <VAT>${data['vat']}</VAT>
    <TOTAL>${data['total']}</TOTAL>
  </VOUCHER>
</TALLYMESSAGE>
''';
    await _shareFile(xml, 'tally_invoice_${data['invoiceNo']}.xml');
  }

  Future<void> exportToOdoo(Map<String, String> data) async {
    final csv = 'TRN,InvoiceNo,Date,VAT,Total\n${data['trn']},${data['invoiceNo']},${data['date']},${data['vat']},${data['total']}';
    await _shareFile(csv, 'odoo_import.csv');
  }

  Future<void> exportToCSV(Map<String, String> data) async {
    final csv = 'Invoice Number,TRN,Date,VAT Amount,Total Amount\n${data['invoiceNo']},${data['trn']},${data['date']},${data['vat']},${data['total']}';
    await _shareFile(csv, 'quickbooks_import.csv');
  }

  Future<void> _shareFile(String content, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: 'VatSnap Export - $fileName');
  }
}
