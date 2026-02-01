import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bachat_core/bachat_core.dart';
import 'package:bachat_core/bachat_core.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  double _monthlyBudget = 50000; // Default budget

  // Statistics
  double _todayTotal = 0;
  double _weekTotal = 0;
  double _monthTotal = 0;
  double _totalExpense = 0;
  List<Map<String, dynamic>> _categoryBreakdown = [];

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get todayTotal => _todayTotal;
  double get weekTotal => _weekTotal;
  double get monthTotal => _monthTotal;
  double get totalExpense => _totalExpense;
  double get monthlyBudget => _monthlyBudget;
  List<Map<String, dynamic>> get categoryBreakdown => _categoryBreakdown;

  ExpenseProvider() {
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBudget = prefs.getDouble('monthly_budget');
    if (savedBudget != null && savedBudget != _monthlyBudget) {
      _monthlyBudget = savedBudget;
      notifyListeners();
    }
  }

  Future<void> setMonthlyBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', budget);
    _monthlyBudget = budget;
    notifyListeners();
  }

  // Fetch all expenses
  Future<void> fetchExpenses({String? startDate, String? endDate, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (category != null) queryParams['category'] = category;

      final response = await _apiService.dio.get(
        '/expenses',
        queryParameters: queryParams,
      );

      _expenses = (response.data as List)
          .map((json) => Expense.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch expenses: $e';
      _isLoading = false;
      notifyListeners();
      print('Fetch Expenses Error: $e');
    }
  }

  // Fetch expense statistics
  Future<void> fetchStats({String? startDate, String? endDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.dio.get(
        '/expenses/stats',
        queryParameters: queryParams,
      );

      _todayTotal = (response.data['today'] as num).toDouble();
      _weekTotal = (response.data['week'] as num).toDouble();
      _monthTotal = (response.data['month'] as num).toDouble();
      _totalExpense = (response.data['total'] as num).toDouble();
      _categoryBreakdown = List<Map<String, dynamic>>.from(response.data['categoryBreakdown']);
      notifyListeners();
    } catch (e) {
      print('Fetch Stats Error: $e');
    }
  }

  // Add expense
  Future<bool> addExpense(Expense expense) async {
    try {
      final response = await _apiService.dio.post(
        '/expenses',
        data: expense.toJson(),
      );

      final newExpense = Expense.fromJson(response.data);
      _expenses.insert(0, newExpense);
      
      // Update stats immediately
      await fetchStats();
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add expense: $e';
      notifyListeners();
      print('Add Expense Error: $e');
      return false;
    }
  }

  // Update expense
  Future<bool> updateExpense(String id, Expense expense) async {
    try {
      final response = await _apiService.dio.put(
        '/expenses/$id',
        data: expense.toJson(),
      );

      final updatedExpense = Expense.fromJson(response.data);
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        await fetchStats();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update expense: $e';
      notifyListeners();
      print('Update Expense Error: $e');
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      await _apiService.dio.delete('/expenses/$id');
      _expenses.removeWhere((e) => e.id == id);
      await fetchStats();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
      print('Delete Expense Error: $e');
      return false;
    }
  }
}
