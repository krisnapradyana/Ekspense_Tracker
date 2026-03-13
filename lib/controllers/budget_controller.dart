import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

/// Controller utama untuk mengatur state dari budget dan pengeluaran.
/// Controller ini juga akan memicu pembaruan UI (warna dinamis) saat budget menipis.
class BudgetController extends ChangeNotifier {
  final List<BudgetCategory> _categories = [];

  final List<Expense> _expenses = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedWidgetBudgetId = 'all';

  List<BudgetCategory> get categories => _categories;
  List<Expense> get expenses => _expenses;
  DateTime get selectedDate => _selectedDate;
  String get selectedWidgetBudgetId => _selectedWidgetBudgetId;

  BudgetController() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String? categoriesJson = prefs.getString('budget_categories');
      if (categoriesJson != null) {
        final List<dynamic> decoded = jsonDecode(categoriesJson);
        _categories.clear();
        _categories.addAll(decoded.map((item) => BudgetCategory.fromMap(item)).toList());
      }
      
      final String? expensesJson = prefs.getString('budget_expenses');
      if (expensesJson != null) {
        final List<dynamic> decoded = jsonDecode(expensesJson);
        _expenses.clear();
        _expenses.addAll(decoded.map((item) => Expense.fromMap(item)).toList());
      }
      
      final String? widgetBudget = prefs.getString('selected_widget_budget_id');
      if (widgetBudget != null) {
        _selectedWidgetBudgetId = widgetBudget;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String categoriesJson = jsonEncode(_categories.map((c) => c.toMap()).toList());
      await prefs.setString('budget_categories', categoriesJson);
      
      final String expensesJson = jsonEncode(_expenses.map((e) => e.toMap()).toList());
      await prefs.setString('budget_expenses', expensesJson);

      await _updateNativeWidget();
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> _updateNativeWidget() async {
    try {
      String amountText = '';
      String titleText = '';

      if (_selectedWidgetBudgetId == 'all' || _selectedWidgetBudgetId.isEmpty) {
        amountText = 'Rp ${totalRemaining.toStringAsFixed(0)}';
        titleText = 'Sisa Budget';
      } else {
        final categoryIndex = _categories.indexWhere((c) => c.id == _selectedWidgetBudgetId);
        if (categoryIndex != -1) {
          final category = _categories[categoryIndex];
          final remaining = category.allocatedAmount - category.spentAmount;
          amountText = 'Rp ${remaining.toStringAsFixed(0)}';
          titleText = category.name;
        } else {
          amountText = 'Rp ${totalRemaining.toStringAsFixed(0)}';
          titleText = 'Sisa Budget';
        }
      }

      await HomeWidget.saveWidgetData<String>('remaining_budget', amountText);
      await HomeWidget.saveWidgetData<String>('widget_title', titleText);
      await HomeWidget.updateWidget(
        name: 'ExpenseWidgetProvider',
        androidName: 'ExpenseWidgetProvider',
        iOSName: 'ExpenseWidget',
      );
    } catch (e) {
      debugPrint('Error updating native widget: $e');
    }
  }
  
  Future<void> updateWidgetSelection(String budgetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_widget_budget_id', budgetId);
      _selectedWidgetBudgetId = budgetId;
      notifyListeners();
      await _updateNativeWidget();
    } catch (e) {
      debugPrint('Error saving widget selection: $e');
    }
  }

  // Hitungan Total Keseluruhan
  double get totalAllocated => _categories.fold(0, (sum, cat) => sum + cat.allocatedAmount);
  double get totalSpent => _categories.fold(0, (sum, cat) => sum + cat.spentAmount);
  double get totalRemaining => totalAllocated - totalSpent;
  double get overallPercentageSpent => totalAllocated == 0 ? 0 : totalSpent / totalAllocated;

  /// Mengubah tanggal terpilih untuk filter pengeluaran
  void updateSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  /// Mengambil daftar pengeluaran berdasarkan tanggal yang dipilih (default: hari ini).
  List<Expense> get dateFilteredExpenses {
    return _expenses.where((e) => 
      e.date.year == _selectedDate.year && e.date.month == _selectedDate.month && e.date.day == _selectedDate.day
    ).toList();
  }

  /// Menambah pengeluaran baru dan otomatis mengupdate sisa budget di kategori terkait
  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    
    final categoryIndex = _categories.indexWhere((c) => c.id == expense.budgetId);
    if (categoryIndex != -1) {
      _categories[categoryIndex].spentAmount += expense.amount;
    }
    
    // Memberitahu semua View terkait untuk me-render ulang UI (termasuk update hero card & warna)
    notifyListeners();
    _saveData();
  }

  /// Menambah kategori budget baru
  void addBudgetCategory(String name, double allocatedAmount) {
    final newCategory = BudgetCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      allocatedAmount: allocatedAmount,
    );
    _categories.add(newCategory);
    notifyListeners();
    _saveData();
  }

  /// Memperbarui kategori budget
  void updateBudgetCategory(String id, String newName, double newAllocatedAmount) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      final oldSpent = _categories[index].spentAmount;
      _categories[index] = BudgetCategory(
        id: id,
        name: newName,
        allocatedAmount: newAllocatedAmount,
        spentAmount: oldSpent,
      );
      notifyListeners();
      _saveData();
    }
  }

  /// Menghapus kategori budget beserta daftar pengeluaran terkait
  void deleteBudgetCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    _expenses.removeWhere((e) => e.budgetId == id);
    notifyListeners();
    _saveData();
  }

  /// Memperbarui pengeluaran dan penyesuaian budget
  void updateExpense(String expenseId, Expense updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      final oldExpense = _expenses[index];
      
      // Kembalikan dana ke budget lama
      final oldCategoryIndex = _categories.indexWhere((c) => c.id == oldExpense.budgetId);
      if (oldCategoryIndex != -1) {
        _categories[oldCategoryIndex].spentAmount -= oldExpense.amount;
      }
      
      // Masukkan pengeluaran dengan data baru
      _expenses[index] = updatedExpense;
      
      // Potong dana dari budget baru (bisa budet yang sama atau pindah kategori)
      final newCategoryIndex = _categories.indexWhere((c) => c.id == updatedExpense.budgetId);
      if (newCategoryIndex != -1) {
        _categories[newCategoryIndex].spentAmount += updatedExpense.amount;
      }
      
      notifyListeners();
      _saveData();
    }
  }

  /// Menghapus pengeluaran dan mengembalikan budget
  void deleteExpense(String expenseId) {
    final expense = _expenses.firstWhere((e) => e.id == expenseId);
    
    // Kembalikan dana
    final categoryIndex = _categories.indexWhere((c) => c.id == expense.budgetId);
    if (categoryIndex != -1) {
      _categories[categoryIndex].spentAmount -= expense.amount;
    }
    
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
    _saveData();
  }
}
