import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/udhaar_provider.dart';
import 'package:bachat_core/bachat_core.dart';
import '../widgets/date_filter_widget.dart';
import 'add_udhaar_screen.dart';

class UdhaarScreen extends StatefulWidget {
  const UdhaarScreen({super.key});

  @override
  State<UdhaarScreen> createState() => _UdhaarScreenState();
}

class _UdhaarScreenState extends State<UdhaarScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<UdhaarProvider>(context, listen: false);
    await provider.fetchUdhaars();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Udhaar'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Lene Hai', icon: Icon(Icons.arrow_downward)),
              Tab(text: 'Dene Hai', icon: Icon(Icons.arrow_upward)),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: Column(
          children: [
            DateFilterWidget(
              onDateSelected: (range) {
                Provider.of<UdhaarProvider>(context, listen: false).fetchUdhaars(
                  startDate: range?.start.toIso8601String(),
                  endDate: range?.end.toIso8601String(),
                );
              },
            ),
            Expanded(
              child: Consumer<UdhaarProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    children: [
                      _buildUdhaarList(provider.leneHai, Colors.green, provider),
                      _buildUdhaarList(provider.deneHai, Colors.red, provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddUdhaarScreen()),
            );
            if (result == true) {
              _loadData();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildUdhaarList(List udhaars, Color color, UdhaarProvider provider) {
    if (udhaars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: udhaars.length,
        itemBuilder: (context, index) {
          final udhaar = udhaars[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: color,
                ),
              ),
              title: Text(
                udhaar.personName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${udhaar.date.day}/${udhaar.date.month}/${udhaar.date.year}'),
                  if (udhaar.notes != null && udhaar.notes!.isNotEmpty)
                    Text(
                      udhaar.notes!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(udhaar.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _showOptionsDialog(udhaar, provider),
                  ),
                ],
              ),
              onLongPress: () {
                _showOptionsDialog(udhaar, provider);
              },
            ),
          );
        },
      ),
    );
  }

  void _showOptionsDialog(udhaar, UdhaarProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(udhaar.personName),
        content: Text('${CurrencyFormatter.format(udhaar.amount)}'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await provider.markAsSettled(udhaar.id!);
              _loadData();
            },
            icon: const Icon(Icons.check_circle, color: Colors.green),
            label: const Text('Mark as Settled'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Udhaar'),
                  content: const Text('Are you sure you want to delete this entry?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await provider.deleteUdhaar(udhaar.id!);
                _loadData();
              }
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
