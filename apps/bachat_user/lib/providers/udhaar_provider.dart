import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bachat_core/bachat_core.dart';
import 'package:bachat_core/bachat_core.dart';

class UdhaarProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Udhaar> _udhaars = [];
  bool _isLoading = false;
  String? _error;

  List<Udhaar> get udhaars => _udhaars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get filtered lists
  List<Udhaar> get leneHai => _udhaars.where((u) => u.type == 'LENE' && !u.isSettled).toList();
  List<Udhaar> get deneHai => _udhaars.where((u) => u.type == 'DENE' && !u.isSettled).toList();

  // Get totals
  double get totalLene => leneHai.fold(0, (sum, u) => sum + u.amount);
  double get totalDene => deneHai.fold(0, (sum, u) => sum + u.amount);

  // Fetch all udhaar entries
  Future<void> fetchUdhaars({String? type, bool? isSettled, String? startDate, String? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (isSettled != null) queryParams['isSettled'] = isSettled.toString();
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.dio.get(
        '/udhaar',
        queryParameters: queryParams,
      );

      _udhaars = (response.data as List)
          .map((json) => Udhaar.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch udhaar: $e';
      _isLoading = false;
      notifyListeners();
      print('Fetch Udhaar Error: $e');
    }
  }

  // Add udhaar
  Future<bool> addUdhaar(Udhaar udhaar) async {
    try {
      final response = await _apiService.dio.post(
        '/udhaar',
        data: udhaar.toJson(),
      );

      final newUdhaar = Udhaar.fromJson(response.data);
      _udhaars.insert(0, newUdhaar);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add udhaar: $e';
      notifyListeners();
      print('Add Udhaar Error: $e');
      return false;
    }
  }

  // Update udhaar
  Future<bool> updateUdhaar(String id, Udhaar udhaar) async {
    try {
      final response = await _apiService.dio.put(
        '/udhaar/$id',
        data: udhaar.toJson(),
      );

      final updatedUdhaar = Udhaar.fromJson(response.data);
      final index = _udhaars.indexWhere((u) => u.id == id);
      if (index != -1) {
        _udhaars[index] = updatedUdhaar;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update udhaar: $e';
      notifyListeners();
      print('Update Udhaar Error: $e');
      return false;
    }
  }

  // Delete udhaar
  Future<bool> deleteUdhaar(String id) async {
    try {
      await _apiService.dio.delete('/udhaar/$id');
      _udhaars.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete udhaar: $e';
      notifyListeners();
      print('Delete Udhaar Error: $e');
      return false;
    }
  }

  // Mark as settled
  Future<bool> markAsSettled(String id) async {
    try {
      final udhaar = _udhaars.firstWhere((u) => u.id == id);
      final updatedUdhaar = Udhaar(
        id: udhaar.id,
        type: udhaar.type,
        personName: udhaar.personName,
        amount: udhaar.amount,
        date: udhaar.date,
        notes: udhaar.notes,
        isSettled: true,
      );
      return await updateUdhaar(id, updatedUdhaar);
    } catch (e) {
      print('Mark Settled Error: $e');
      return false;
    }
  }
}
