import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'utils/theme.dart';
import 'screens/biometric_lock_screen.dart';
import 'services/notification_service.dart';
import 'providers/category_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirstTime = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('isFirstTime') ?? true;
  } catch (e) {
    debugPrint('Error loading SharedPreferences: $e');
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Error initializing NotificationService: $e');
  }

  runApp(MyApp(isFirstTime: isFirstTime));
}

// ... (existing imports)

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..fetchTransactions(),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..fetchCategories(),
          lazy: false,
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Money Report',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            debugShowCheckedModeBanner: false,
            home: settings.isBiometricEnabled
                ? BiometricLockScreen(
                    child: isFirstTime
                        ? const WelcomeScreen()
                        : const MainScreen(),
                  )
                : (isFirstTime ? const WelcomeScreen() : const MainScreen()),
          );
        },
      ),
    );
  }
}
