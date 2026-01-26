import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currencyCode = 'IDR';
  String _currencySymbol = 'Rp';
  double _monthlyBudget = 0.0;
  bool _isBiometricEnabled = false;
  bool _isDailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(
    hour: 20,
    minute: 0,
  ); // Default 8 PM

  ThemeMode get themeMode => _themeMode;
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  double get monthlyBudget => _monthlyBudget;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex =
        prefs.getInt('themeMode') ?? 0; // 0=system, 1=light, 2=dark
    _themeMode = ThemeMode.values[themeIndex];

    _currencyCode = prefs.getString('currencyCode') ?? 'IDR';
    _currencySymbol = prefs.getString('currencySymbol') ?? 'Rp';
    _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0.0;
    _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    _isDailyReminderEnabled = prefs.getBool('isDailyReminderEnabled') ?? false;

    final int reminderHour = prefs.getInt('dailyReminderHour') ?? 20;
    final int reminderMinute = prefs.getInt('dailyReminderMinute') ?? 0;
    _dailyReminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    int index = 0;
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await prefs.setInt('themeMode', index);
  }

  Future<void> setCurrency(String code, String symbol) async {
    _currencyCode = code;
    _currencySymbol = symbol;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCode', code);
    await prefs.setString('currencySymbol', symbol);
  }

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyBudget', amount);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricEnabled', enabled);
    notifyListeners();
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _isDailyReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDailyReminderEnabled', enabled);

    if (enabled) {
      final granted = await NotificationService().requestPermissions();
      if (granted) {
        await NotificationService().scheduleDailyReminder(
          id: 1,
          title: 'Daily Reminder',
          body: 'Don\'t forget to record your transactions today!',
          time: _dailyReminderTime,
        );
      } else {
        // Permission denied, maybe revert or just don't schedule
        _isDailyReminderEnabled = false; // Revert for UI consistency
        await prefs.setBool('isDailyReminderEnabled', false);
      }
    } else {
      await NotificationService().cancelNotification(1);
    }
    notifyListeners();
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    _dailyReminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyReminderHour', time.hour);
    await prefs.setInt('dailyReminderMinute', time.minute);

    if (_isDailyReminderEnabled) {
      await NotificationService().scheduleDailyReminder(
        id: 1,
        title: 'Daily Reminder',
        body: 'Don\'t forget to record your transactions today!',
        time: time,
      );
    }
    notifyListeners();
  }
}
