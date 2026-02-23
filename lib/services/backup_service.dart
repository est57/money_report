import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';

class BackupService {
  final TransactionProvider transactionProvider;
  final SettingsProvider settingsProvider;
  final CategoryProvider categoryProvider;

  BackupService(
    this.transactionProvider,
    this.settingsProvider,
    this.categoryProvider,
  );

  Future<void> exportData() async {
    try {
      // 1. Collect Data
      final transactions = transactionProvider.transactions
          .map((tx) => tx.toMap())
          .toList();
      final recurring = transactionProvider.recurringTransactions
          .map((tx) => tx.toMap())
          .toList();

      final categories = categoryProvider.categories
          .map((cat) => cat.toMap())
          .toList();

      final settings = {
        'currencyCode': settingsProvider.currencyCode,
        'currencySymbol': settingsProvider.currencySymbol,
        'monthlyBudget': settingsProvider.monthlyBudget,
      };

      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'settings': settings,
        'transactions': transactions,
        'recurring_transactions': recurring,
        'categories': categories,
      };

      // 2. Convert to JSON
      final jsonString = jsonEncode(backupData);

      // 3. Write to File
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'money_report_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // 4. Share File
      await Share.shareXFiles([XFile(file.path)], text: 'Money Report Backup');
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<void> importData() async {
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        Map<String, dynamic> data = jsonDecode(jsonString);

        // 2. Validate (Basic)
        if (!data.containsKey('transactions') ||
            !data.containsKey('recurring_transactions')) {
          throw Exception('Invalid backup file format');
        }

        // 3. Import (Delegate to Provider)
        await transactionProvider.importData(data);

        // Import Settings if available
        if (data.containsKey('settings')) {
          final settings = data['settings'];
          settingsProvider.setCurrency(
            settings['currencyCode'],
            settings['currencySymbol'],
          );
          settingsProvider.setMonthlyBudget(
            settings['monthlyBudget']?.toDouble() ?? 0.0,
          );
        }

        // Import Categories if available (for backward compatibility if old backups don't have it)
        if (data.containsKey('categories')) {
          await categoryProvider.importData(data['categories']);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
