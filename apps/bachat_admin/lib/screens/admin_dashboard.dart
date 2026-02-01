import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bachat_core/bachat_core.dart';
import '../providers/admin_provider.dart';
import 'user_management_screen.dart';
import 'analytics_screen.dart';
import 'send_notification_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch stats on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bachat-G Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchStats(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text('Error: ${provider.error}'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatCard(
                        'Total Users',
                        '${provider.stats['totalUsers'] ?? 0}',
                        Icons.people,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Monthly Expense Volume',
                        CurrencyFormatter.format((provider.stats['totalMonthlyExpenses'] as num?)?.toDouble() ?? 0),
                        Icons.monetization_on,
                        Colors.green,
                      ),
                       const SizedBox(height: 16),
                      _buildStatCard(
                        'Active Udhaar Volume',
                        CurrencyFormatter.format((provider.stats['totalActiveUdhaar'] as num?)?.toDouble() ?? 0),
                        Icons.credit_score,
                        Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.people),
                        label: const Text('Manage Users'),
                        onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.analytics),
                        label: const Text('View Analytics'),
                        onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                       ElevatedButton.icon(
                        icon: const Icon(Icons.notifications),
                        label: const Text('Send Notification'),
                        onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const SendNotificationScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
