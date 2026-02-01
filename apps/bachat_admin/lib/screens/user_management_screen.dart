import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bachat_core/bachat_core.dart';
import '../providers/admin_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
      ),
      body: provider.isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : provider.users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return UserListTile(user: user);
                  },
                ),
    );
  }
}

class UserListTile extends StatelessWidget {
  final User user;

  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final deviceInfo = user.deviceInfo ?? {};
    final model = deviceInfo['model'] ?? 'Unknown Device';
    final platform = deviceInfo['platform'] ?? '';
    final lastLogin = user.lastLogin != null 
        ? DateFormat('MMM d, h:mm a').format(user.lastLogin!.toLocal()) 
        : 'Never';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.profilePicture ?? ''),
          child: user.profilePicture == null ? Text(user.fullName?[0] ?? 'U') : null,
        ),
        title: Text(user.fullName ?? 'No Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(platform == 'android' ? Icons.android : platform == 'ios' ? Icons.apple : Icons.devices, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$model • Active: $lastLogin', style: const TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)));
        },
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
    final User user;
    const UserDetailScreen({super.key, required this.user});

    @override
    Widget build(BuildContext context) {
        final deviceInfo = user.deviceInfo ?? {};
        
        return Scaffold(
            appBar: AppBar(title: Text(user.fullName ?? 'User Details')),
            body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                    Center(
                        child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(user.profilePicture ?? ''),
                        ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                        leading: const Icon(Icons.email),
                    ),
                    ListTile(
                        title: const Text('Mobile'),
                        subtitle: Text(user.mobileNumber ?? 'N/A'),
                        leading: const Icon(Icons.phone),
                    ),
                    const Divider(),
                    const Text('Device Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildInfoRow('Model', deviceInfo['model']),
                    _buildInfoRow('Brand', deviceInfo['brand']),
                    _buildInfoRow('OS Version', deviceInfo['version'] ?? deviceInfo['systemVersion']),
                    _buildInfoRow('App Version', '${deviceInfo['appVersion']} (${deviceInfo['buildNumber']})'),
                    _buildInfoRow('Platform', deviceInfo['platform']),
                    const Divider(),
                    const Text('Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     ListTile(
                        title: const Text('Last Login'),
                        subtitle: Text(user.lastLogin != null ? DateFormat.yMMMMEEEEd().add_jm().format(user.lastLogin!.toLocal()) : 'Never'),
                        leading: const Icon(Icons.access_time),
                    ),
                     ListTile(
                        title: const Text('IP Address'),
                        subtitle: Text(user.ipAddress ?? 'Unknown'),
                        leading: const Icon(Icons.wifi),
                    ),
                ],
            ),
        );
    }

    Widget _buildInfoRow(String label, String? value) {
        if (value == null) return const SizedBox.shrink();
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
                children: [
                    Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Expanded(child: Text(value)),
                ],
            ),
        );
    }
}
