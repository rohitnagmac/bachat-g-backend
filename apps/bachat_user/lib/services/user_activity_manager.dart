import 'package:flutter/material.dart';
import 'package:bachat_core/bachat_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityManager extends WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  DateTime? _startTime;

  // Singleton
  static final UserActivityManager _instance = UserActivityManager._internal();
  factory UserActivityManager() => _instance;
  UserActivityManager._internal();

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _recordAppOpen(); // Record open on launch
    _startTime = DateTime.now();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recordAppOpen();
      _startTime = DateTime.now();
    } else if (state == AppLifecycleState.paused) {
      _recordSession();
    }
  }

  Future<void> _recordAppOpen() async {
    try {
        // Only record if user is logged in (check token)
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('token')) return;

        await _apiService.dio.post('/analytics/activity', data: {
            'type': 'app_open'
        });
        print('Analytics: App Open Recorded');
    } catch (e) {
        print('Analytics Error (Open): $e');
    }
  }

  Future<void> _recordSession() async {
    if (_startTime == null) return;
    
    final endTime = DateTime.now();
    final durationSeconds = endTime.difference(_startTime!).inSeconds;

    // Filter out very short sessions (< 2 seconds) or accidental backgrounding
    if (durationSeconds < 2) return;

    try {
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('token')) return;

        await _apiService.dio.post('/analytics/activity', data: {
            'type': 'session',
            'duration': durationSeconds
        });
        print('Analytics: Session Recorded ($durationSeconds s)');
    } catch (e) {
        print('Analytics Error (Session): $e');
    }
  }
}
