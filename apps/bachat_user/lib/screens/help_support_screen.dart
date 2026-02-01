import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItem(context, Icons.question_answer, 'FAQs', 'Frequently asked questions'),
          _buildItem(context, Icons.email, 'Contact Us', 'Support@bachatg.com'),
          _buildItem(context, Icons.description, 'Terms of Service', 'Read our terms'),
          _buildItem(context, Icons.privacy_tip, 'Privacy Policy', 'Your data is safe'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: () {
          // Placeholder for actual navigation or action
        },
      ),
    );
  }
}
