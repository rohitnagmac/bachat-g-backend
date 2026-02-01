import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bachat_core/bachat_core.dart';
import 'package:bachat_core/bachat_core.dart';
import '../services/fcm_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '151142422589-i9592musm5jj2maak8a4udtabj36r64b.apps.googleusercontent.com',
  );
  final ApiService _apiService = ApiService();
  
  // User Data
  String? _id;
  String? _fullName;
  String? _email;
  String? _mobileNumber;
  String? _profilePicture;
  String? _token;
  bool _isNewUser = false;

  // Getters
  String? get id => _id;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get mobileNumber => _mobileNumber;
  String? get profilePicture => _profilePicture;
  String? get token => _token;
  bool get isNewUser => _isNewUser;

  Future<bool> signInWithGoogle() async {
    try {
      print('DEBUG: AppConstants.baseUrl = ${AppConstants.baseUrl}');
      print('Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('User canceled sign-in');
        return false; // User canceled
      }

      print('Getting authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      print('ID Token: ${idToken != null ? "Present (${idToken.substring(0, 20)}...)" : "MISSING!"}');
      print('Access Token: ${accessToken != null ? "Present" : "Missing"}');

      if (idToken != null) {
        // Preferred: Use ID token for backend authentication
        
        // Capture Device Info
        final deviceInfoPlugin = DeviceInfoPlugin();
        Map<String, dynamic> deviceData = {};
        
        try {
          if (kIsWeb) {
              final webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
              deviceData = {
                  'model': webBrowserInfo.userAgent,
                  'platform': 'web',
              };
          } else if (Platform.isAndroid) {
              final androidInfo = await deviceInfoPlugin.androidInfo;
              deviceData = {
                  'model': androidInfo.model,
                  'brand': androidInfo.brand,
                  'device': androidInfo.device,
                  'version': androidInfo.version.release,
                  'platform': 'android',
              };
          } else if (Platform.isIOS) {
              final iosInfo = await deviceInfoPlugin.iosInfo;
              deviceData = {
                  'model': iosInfo.utsname.machine,
                  'name': iosInfo.name,
                  'systemName': iosInfo.systemName,
                  'systemVersion': iosInfo.systemVersion,
                  'platform': 'ios',
              };
          }
          
          final packageInfo = await PackageInfo.fromPlatform();
          deviceData['appVersion'] = packageInfo.version;
          deviceData['buildNumber'] = packageInfo.buildNumber;
          
        } catch (e) {
            print('Error capturing device info: $e');
        }

        return await _authenticateWithBackend(idToken, deviceData);
      } else if (accessToken != null) {
        // Fallback for web: Use access token to get user info
        print('Using access token fallback (web platform)');
        return await _authenticateWithAccessToken(accessToken, googleUser);
      } else {
        print('ERROR: Neither idToken nor accessToken available!');
        return false;
      }
    } catch (error) {
      print('Google Sign In Error: $error');
      return false;
    }
  }

  Future<bool> _authenticateWithAccessToken(String accessToken, GoogleSignInAccount googleUser) async {
    try {
      print('Authenticating with access token for web...');
      final String fullUrl = '${_apiService.dio.options.baseUrl}/auth/google-web';
      print('DEBUG: Full Request URL = $fullUrl');
      
      // For web, we'll send user info directly since we can't verify the token server-side easily
      final response = await _apiService.dio.post('/auth/google-web', data: {
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
        'id': googleUser.id,
      });

      print('Backend response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _setUserData(response.data);
        return true;
      }
      return false;
    } catch (e) {
       print('Backend Auth Error (access token): $e');
       if (e is DioException) {
         print('DioException response: ${e.response?.data}');
       }
       return false;
    }
  }

  Future<bool> _authenticateWithBackend(String idToken, [Map<String, dynamic>? deviceData]) async {
    try {
      print('Attempting backend auth with token: ${idToken.substring(0, 20)}...');
      print('Backend URL: ${AppConstants.baseUrl}/auth/google');
      
      final response = await _apiService.dio.post('/auth/google', data: {
        'token': idToken,
        'deviceInfo': deviceData
      });

      print('Backend response status: ${response.statusCode}');
      print('Backend response data: ${response.data}');

      if (response.statusCode == 200) {
        _setUserData(response.data);
        return true;
      }
      return false;
    } catch (e) {
       print('Backend Auth Error: $e');
       print('Error type: ${e.runtimeType}');
       if (e is DioException) {
         print('DioException message: ${e.message}');
         print('DioException response: ${e.response?.data}');
       }
       return false;
    }
  }
  
  Future<bool> updateProfile(String name, String mobile) async {
    try {
      final response = await _apiService.dio.put('/auth/profile', data: {
        'fullName': name,
        'mobileNumber': mobile,
      });

      if (response.statusCode == 200) {
        _setUserData(response.data);
        _isNewUser = false; // Profile completed
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
       print('Profile Update Error: $e');
       return false;
    }
  }

  Future<bool> updateProfilePicture(String base64Image) async {
    try {
      final response = await _apiService.dio.put('/auth/profile', data: {
        'profilePicture': base64Image,
      });

      if (response.statusCode == 200) {
        _setUserData(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
       print('Profile Picture Update Error: $e');
       return false;
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      if (_token == null) return;
      await _apiService.dio.put('/auth/fcm-token', data: {
        'fcmToken': fcmToken,
      });
      print('FCM Token updated on server');
    } catch (e) {
      print('FCM Token update error: $e');
    }
  }

  void _setUserData(Map<String, dynamic> data) async {
    _id = data['_id'];
    _fullName = data['fullName'];
    _email = data['email'];
    _mobileNumber = data['mobileNumber'];
    _profilePicture = data['profilePicture'];
    _token = data['token'];
    _isNewUser = data['isNewUser'] ?? false;
    
    // Set token for future requests
    if (_token != null) {
        _apiService.setToken(_token!);
        
        // Save to persistent storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));

        // Update FCM token on server
        FcmService().getToken().then((fcmToken) {
          if (fcmToken != null) {
            updateFcmToken(fcmToken);
          }
        });
    }
    
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('user_data')) return false;

      final userData = jsonDecode(prefs.getString('user_data')!) as Map<String, dynamic>;
      _setUserData(userData);
      return true;
    } catch (e) {
      print('Auto-login error: $e');
      return false;
    }
  }
  
  Future<void> logout() async {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      
      _id = null;
      _token = null;
      _fullName = null;
      _email = null;
      _mobileNumber = null;
      _profilePicture = null;
      _apiService.setToken(''); // Clear token
      notifyListeners();
  }
}
