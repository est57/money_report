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
}
