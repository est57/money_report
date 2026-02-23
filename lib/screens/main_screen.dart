import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'report_screen.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart'; // Import SettingsScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReportScreen(),
    const StatsScreen(),
    const SettingsScreen(), // Use SettingsScreen
  ];

  void _onItemTapped(int index) {
    // Updated safety check for the new number of screens
    if (index == 3 && _screens.length < 4) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 70, // Increased height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                icon: HugeIcons.strokeRoundedHome01,
                activeIcon: HugeIcons.strokeRoundedHome01,
                label: 'Home',
                index: 0,
              ),
              _buildTabItem(
                icon: HugeIcons.strokeRoundedDocumentValidation,
                activeIcon: HugeIcons.strokeRoundedDocumentValidation,
                label: 'Report',
                index: 1,
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildTabItem(
                icon: HugeIcons.strokeRoundedPieChart,
                activeIcon: HugeIcons.strokeRoundedPieChart,
                label: 'Stats',
                index: 2,
              ),
              _buildTabItem(
                icon: HugeIcons.strokeRoundedSettings01,
                activeIcon: HugeIcons.strokeRoundedSettings01,
                label: 'Settings',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required dynamic icon,
    required dynamic activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ), // Reduced padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: isSelected ? activeIcon : icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Slightly reduced font size
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
