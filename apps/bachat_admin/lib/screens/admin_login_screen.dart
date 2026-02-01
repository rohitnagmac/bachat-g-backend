import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:bachat_core/bachat_core.dart';
import '../providers/admin_provider.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  bool _otpSent = false;

  Future<void> _handleRequestOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
        setState(() => _error = 'Please enter email');
        return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      await apiService.dio.post('/auth/otp/request', data: {
        'email': email,
      });

      setState(() {
        _otpSent = true;
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent! Check server console.'))
        );
      });
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _handleVerifyOtp() async {
     final email = _emailController.text.trim();
     final otp = _otpController.text.trim();

     if (otp.length != 6) {
        setState(() => _error = 'Please enter 6-digit OTP');
        return;
     }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.dio.post('/auth/otp/verify', data: {
        'email': email,
        'otp': otp
      });

      final token = response.data['token'];
      final role = response.data['role'];

      if (role != 'admin') {
        throw Exception('Access Denied: You are not an admin.');
      }

      if (mounted) {
        Provider.of<AdminProvider>(context, listen: false).setToken(token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    } catch (e) {
        _handleError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleError(dynamic e) {
      if (e is DioException) {
          setState(() {
              _isLoading = false;
              _error = e.response?.data['message'] ?? 'Request Failed';
          });
      } else {
          setState(() {
              _isLoading = false;
              _error = e.toString();
          });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),
                  
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email)
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_otpSent,
                  ),
                  const SizedBox(height: 16),
                  
                  if (_otpSent) ...[
                      TextField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                            labelText: 'Enter OTP (Check Console)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock)
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleVerifyOtp,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text('Verify & Login'),
                      ),
                       TextButton(
                        onPressed: () => setState(() {
                            _otpSent = false;
                            _error = null;
                            _otpController.clear();
                        }),
                        child: const Text('Change Email'),
                      ),
                  ] else 
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRequestOtp,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text('Send OTP'),
                      ),
                ],
              ),
            )
        ),
      ),
    );
  }
}
