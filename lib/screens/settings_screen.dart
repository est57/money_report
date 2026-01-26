import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import 'recurring_transactions_screen.dart';
import 'backup_screen.dart';
import 'manage_categories_screen.dart';
import '../services/biometric_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionHeader('General', context),
              _buildSettingsItem(
                context: context,
                icon: HugeIcons.strokeRoundedMoney03,
                color: Colors.orange,
                title: 'Currency',
                trailingText: settings.currencyCode,
                onTap: () => _showCurrencyDialog(context),
              ),
              _buildSettingsItem(
                context: context,
                icon: HugeIcons.strokeRoundedAnalytics01,
                color: Colors.teal,
                title: 'Monthly Budget',
                trailingText: settings.monthlyBudget > 0
                    ? '${settings.currencySymbol} ${settings.monthlyBudget.toStringAsFixed(0)}'
                    : 'Not Set',
                onTap: () => _showBudgetDialog(context),
              ),
              _buildSettingsItem(
                context: context,
                icon: HugeIcons.strokeRoundedGrid,
                color: Colors.indigo,
                title: 'Manage Categories',
                trailingText: '',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ManageCategoriesScreen(),
                    ),
                  );
                },
              ),
              FutureBuilder<bool>(
                future: BiometricService.isBiometricAvailable(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!) {
                    return const SizedBox.shrink();
                  }
                  return _buildSwitchItem(
                    context: context,
                    icon: HugeIcons.strokeRoundedFingerPrint,
                    color: Colors.green,
                    title: 'App Lock (Biometric)',
                    value: settings.isBiometricEnabled,
                    onChanged: (val) async {
                      if (val) {
                        final authenticated =
                            await BiometricService.authenticate();
                        if (authenticated) {
                          settings.setBiometricEnabled(true);
                        }
                      } else {
                        settings.setBiometricEnabled(false);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Notifications', context),
              _buildSwitchItem(
                context: context,
                icon: HugeIcons.strokeRoundedNotification01,
                color: Colors.redAccent,
                title: 'Daily Reminder',
                value: settings.isDailyReminderEnabled,
                onChanged: (val) => settings.setDailyReminderEnabled(val),
              ),
              if (settings.isDailyReminderEnabled)
                _buildSettingsItem(
                  context: context,
                  icon: HugeIcons.strokeRoundedTime01,
                  color: Colors.blue,
                  title: 'Reminder Time',
                  trailingText: settings.dailyReminderTime.format(context),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: settings.dailyReminderTime,
                    );
                    if (picked != null) {
                      settings.setDailyReminderTime(picked);
                    }
                  },
                ),
              const SizedBox(height: 20),
              _buildSectionHeader('Appearance', context),
              _buildSettingsItem(
                context: context,
                icon: HugeIcons.strokeRoundedPaintBoard,
                color: Colors.purple,
                title: 'Theme',
                trailingText: settings.themeMode.name.toUpperCase(),
                onTap: () => _showThemeDialog(context),
              ),
              _buildSettingsItem(
                context: context,
                icon: HugeIcons.strokeRoundedRepeat,
                color: Colors.blueAccent,
                title: 'Recurring Transactions',
                trailingText: 'Manage',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RecurringTransactionsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context: context,
                icon: HugeIcons.strokeRoundedCloudServer,
                color: Colors.orange,
                title: 'Backup & Restore',
                trailingText: '',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BackupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('About', context),
              _buildSettingsItem(
                context: context,
                icon: HugeIcons.strokeRoundedInformationCircle,
                color: Colors.blue,
                title: 'Version',
                trailingText: '1.0.0',
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _showSelectionModal(
      context: context,
      title: 'Select Currency',
      options: [
        _buildModalOption(
          context: context,
          title: 'IDR (Rp)',
          isSelected: settings.currencyCode == 'IDR',
          onTap: () {
            settings.setCurrency('IDR', 'Rp');
            Navigator.pop(context);
          },
        ),
        _buildModalOption(
          context: context,
          title: 'USD (\$)',
          isSelected: settings.currencyCode == 'USD',
          onTap: () {
            settings.setCurrency('USD', '\$');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final controller = TextEditingController(
      text: settings.monthlyBudget > 0
          ? settings.monthlyBudget.toStringAsFixed(0)
          : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAnalytics01,
                  color: Colors.teal,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Set Monthly Budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your target monthly spending limit',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      settings.currencySymbol,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(controller.text) ?? 0.0;
                        settings.setMonthlyBudget(amount);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _showSelectionModal(
      context: context,
      title: 'Select Theme',
      options: [
        _buildModalOption(
          context: context,
          title: 'Light',
          icon: HugeIcons.strokeRoundedSun03,
          isSelected: settings.themeMode == ThemeMode.light,
          onTap: () {
            settings.setThemeMode(ThemeMode.light);
            Navigator.pop(context);
          },
        ),
        _buildModalOption(
          context: context,
          title: 'Dark',
          icon: HugeIcons.strokeRoundedMoon02,
          isSelected: settings.themeMode == ThemeMode.dark,
          onTap: () {
            settings.setThemeMode(ThemeMode.dark);
            Navigator.pop(context);
          },
        ),
        _buildModalOption(
          context: context,
          title: 'System',
          icon: HugeIcons.strokeRoundedSmartPhone01,
          isSelected: settings.themeMode == ThemeMode.system,
          onTap: () {
            settings.setThemeMode(ThemeMode.system);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showSelectionModal({
    required BuildContext context,
    required String title,
    required List<Widget> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...options,
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required BuildContext context,
    required String title,
    dynamic icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: theme.primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              HugeIcon(
                icon: icon,
                color: isSelected ? theme.primaryColor : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 15),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.primaryColor
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              HugeIcon(
                icon: HugeIcons.strokeRoundedTick02,
                color: theme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade400
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required dynamic icon,
    required Color color,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    Border? border;
    if (theme.cardTheme.shape is RoundedRectangleBorder) {
      final side = (theme.cardTheme.shape as RoundedRectangleBorder).side;
      if (side != BorderSide.none) {
        border = Border.fromBorderSide(side);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.brightness == Brightness.dark
            ? []
            : AppTheme.softShadow,
        border: border,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(icon: icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 8),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required dynamic icon,
    required Color color,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    Border? border;
    if (theme.cardTheme.shape is RoundedRectangleBorder) {
      final side = (theme.cardTheme.shape as RoundedRectangleBorder).side;
      if (side != BorderSide.none) {
        border = Border.fromBorderSide(side);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.brightness == Brightness.dark
            ? []
            : AppTheme.softShadow,
        border: border,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(icon: icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.primaryColor,
        ),
      ),
    );
  }
}
