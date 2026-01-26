import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';

class PdfGenerator {
  static Future<File> generateReport({
    required List<TransactionModel> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required double totalIncome,
    required double totalExpense,
    required String currencySymbol,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: currencySymbol,
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(startDate, endDate),
            pw.SizedBox(height: 20),
            _buildSummary(
              totalIncome,
              totalExpense,
              currencyFormat,
              currencySymbol,
            ),
            pw.SizedBox(height: 20),
            _buildTable(transactions, currencyFormat),
          ];
        },
        footer: (context) => _buildFooter(context),
      ),
    );

    return await _saveDocument(pdf);
  }

  static pw.Widget _buildHeader(DateTime startDate, DateTime endDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Money Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal,
              ),
            ),
            pw.Text(
              'Transaction Report',
              style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.Divider(color: PdfColors.grey300),
      ],
    );
  }

  static pw.Widget _buildSummary(
    double income,
    double expense,
    NumberFormat currencyFormat,
    String symbol,
  ) {
    final net = income - expense;
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Income',
            income,
            PdfColors.green700,
            currencyFormat,
          ),
          _buildSummaryItem(
            'Expense',
            expense,
            PdfColors.red700,
            currencyFormat,
          ),
          _buildSummaryItem(
            'Net Total',
            net,
            net >= 0 ? PdfColors.teal : PdfColors.red700,
            currencyFormat,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    double amount,
    PdfColor color,
    NumberFormat format,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          format.format(amount),
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(
    List<TransactionModel> transactions,
    NumberFormat currencyFormat,
  ) {
    return pw.Table.fromTextArray(
      headers: ['Date', 'Category', 'Title', 'Amount'],
      data: transactions.map((tx) {
        return [
          DateFormat('dd MMM yyyy').format(tx.date),
          tx.category,
          tx.title,
          currencyFormat.format(tx.isExpense ? -tx.amount : tx.amount),
        ];
      }).toList(),
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
        ),
      ),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount} - Generated on ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
      ),
    );
  }

  static Future<File> _saveDocument(pw.Document pdf) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/money_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
