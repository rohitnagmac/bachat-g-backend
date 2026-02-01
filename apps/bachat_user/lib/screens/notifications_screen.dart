import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _expenseAlerts = true;
  bool _budgetReminders = true;
  bool _udhaarAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Expense Alerts'),
            subtitle: const Text('Get notified when you add an expense'),
            value: _expenseAlerts,
            onChanged: (val) => setState(() => _expenseAlerts = val),
          ),
          SwitchListTile(
            title: const Text('Budget Reminders'),
            subtitle: const Text('Alerts when you exceed 80% budget'),
            value: _budgetReminders,
            onChanged: (val) => setState(() => _budgetReminders = val),
          ),
          SwitchListTile(
            title: const Text('Udhaar Reminders'),
            subtitle: const Text('Reminders for pending udhaars'),
            value: _udhaarAlerts,
            onChanged: (val) => setState(() => _udhaarAlerts = val),
          ),
        ],
      ),
    );
  }
}
