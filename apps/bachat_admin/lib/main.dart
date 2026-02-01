import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bachat_core/bachat_core.dart';
import 'providers/admin_provider.dart';
import 'screens/admin_login_screen.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Bachat-G Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AdminLoginScreen(),
      ),
    );
  }
}
