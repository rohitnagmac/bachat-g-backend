import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bachat_core/bachat_core.dart';

class AdminProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  List<User> _users = [];
  bool _isLoadingUsers = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoadingUsers => _isLoadingUsers;
  Map<String, dynamic> get stats => _stats;
  List<User> get users => _users;
  String? get error => _error;

  String? _token;
  String? get token => _token;

  void setToken(String token) {
    _token = token;
    _apiService.setToken(token);
    notifyListeners();
  }

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/admin/stats');
      _stats = response.data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch stats: $e';
      _isLoading = false;
      notifyListeners();
      print('Admin Stats Error: $e');
    }
  }

  Future<void> fetchUsers() async {
    _isLoadingUsers = true;
    notifyListeners();

    try {
        final response = await _apiService.dio.get('/admin/users');
        final List<dynamic> data = response.data;
        _users = data.map((json) => User.fromJson(json)).toList();
        _isLoadingUsers = false;
        notifyListeners();
    } catch (e) {
        print('Fetch Users Error: $e');
        _isLoadingUsers = false;
        notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchAnalytics(int days) async {
    try {
        final response = await _apiService.dio.get('/admin/analytics', queryParameters: {'days': days});
        return response.data;
    } catch (e) {
        print('Fetch Analytics Error: $e');
        return {};
    }
  }

  Future<bool> sendNotification({
    String? title, 
    required String body, 
    String? imageUrl,
    File? imageFile,
    List<String>? targetUserIds
  }) async {
    try {
        final formData = FormData.fromMap({
            'title': title,
            'body': body,
            'imageUrl': imageUrl,
            'targetUserIds': targetUserIds,
        });

        if (imageFile != null) {
            formData.files.add(MapEntry(
                'image',
                await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last)
            ));
        }

        await _apiService.dio.post('/notifications/send', data: formData);
        return true;
    } catch (e) {
        print('Send Notification Error: $e');
        _error = 'Failed to send notification';
        notifyListeners();
        return false;
    }
  }
}
