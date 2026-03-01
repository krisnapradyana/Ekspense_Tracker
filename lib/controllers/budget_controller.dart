import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

/// Controller utama untuk mengatur state dari budget dan pengeluaran.
/// Controller ini juga akan memicu pembaruan UI (warna dinamis) saat budget menipis.
class BudgetController extends ChangeNotifier {
  final List<BudgetCategory> _categories = [];

  final List<Expense> _expenses = [];
  DateTime _selectedDate = DateTime.now();

  List<BudgetCategory> get categories => _categories;
  List<Expense> get expenses => _expenses;
  DateTime get selectedDate => _selectedDate;

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
    }
  }

  /// Menghapus kategori budget beserta daftar pengeluaran terkait
  void deleteBudgetCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    _expenses.removeWhere((e) => e.budgetId == id);
    notifyListeners();
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
  }
}
