import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../utils/theme.dart';
import '../utils/icon_registry.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  final String initialType; // 'Expense' or 'Income'

  const AddEditCategoryScreen({
    super.key,
    this.category,
    required this.initialType,
  });

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _nameController = TextEditingController();
  late String _selectedIconKey;
  late int _selectedColor;
  late String _selectedType;

  final List<int> _colors = [
    0xFFE53935, // Red
    0xFFD81B60, // Pink
    0xFF8E24AA, // Purple
    0xFF3949AB, // Indigo
    0xFF1E88E5, // Blue
    0xFF039BE5, // Light Blue
    0xFF00ACC1, // Cyan
    0xFF00897B, // Teal
    0xFF43A047, // Green
    0xFF7CB342, // Light Green
    0xFFC0CA33, // Lime
    0xFFFDD835, // Yellow
    0xFFFFB300, // Amber
    0xFFFB8C00, // Orange
    0xFFF4511E, // Deep Orange
    0xFF6D4C41, // Brown
    0xFF757575, // Grey
    0xFF546E7A, // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIconKey = widget.category!.iconKey;
      _selectedColor = widget.category!.color;
      _selectedType = widget.category!.type;
    } else {
      _selectedIconKey = 'other';
      _selectedColor = _colors[0];
      _selectedType = widget.initialType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    final newCategory = CategoryModel(
      id: widget.category?.id,
      name: _nameController.text,
      type: _selectedType,
      iconKey: _selectedIconKey,
      color: _selectedColor,
    );

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    if (widget.category != null) {
      provider.updateCategory(newCategory);
    } else {
      provider.addCategory(newCategory);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category != null ? 'Edit Category' : 'Add Category',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Color Picker
            const Text(
              'Select Color',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Icon Picker
            const Text(
              'Select Icon',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: IconRegistry.iconMap.entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconKey = entry.key;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedIconKey == entry.key
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: _selectedIconKey == entry.key
                          ? Border.all(color: AppTheme.primaryColor, width: 2)
                          : null,
                    ),
                    child: HugeIcon(
                      icon: entry.value,
                      color: _selectedIconKey == entry.key
                          ? AppTheme.primaryColor
                          : Colors.black54,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Category',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
