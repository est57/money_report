import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/database_helper.dart';
import '../utils/icon_registry.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<CategoryModel> get categories => _categories;

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 'Expense').toList();

  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 'Income').toList();

  Future<void> fetchCategories() async {
    try {
      _categories = await _dbHelper.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await _dbHelper.insertCategory(category);
    await fetchCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _dbHelper.updateCategory(category);
    await fetchCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _dbHelper.deleteCategory(id);
    await fetchCategories();
  }

  // Helper to get Icon data from key
  dynamic getIcon(String key) {
    return IconRegistry.getIcon(key);
  }

  Future<void> importData(List<dynamic> backupCategories) async {
    // 1. Wipe existing categories to ensure a clean restore
    await _dbHelper.deleteAllCategories();

    // 2. Insert backed up categories
    for (var catMap in backupCategories) {
      final original = CategoryModel.fromMap(catMap);
      final newCat = CategoryModel(
        name: original.name,
        type: original.type,
        iconKey: original.iconKey,
        color: original.color,
        budget: original.budget,
      );
      await _dbHelper.insertCategory(newCat);
    }

    // 3. Refresh Provider State
    await fetchCategories();
  }
}
