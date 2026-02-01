import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../widgets/month_filter_widget.dart';
import 'package:bachat_core/bachat_core.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Fetch triggered by MonthFilterWidget's initial callback or default state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categoryBreakdown.isEmpty) {
            return const Center(child: Text('No data to display analytics'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonthFilterWidget(
                  onMonthSelected: (range) {
                    Provider.of<ExpenseProvider>(context, listen: false).fetchStats(
                      startDate: range.start.toIso8601String(),
                      endDate: range.end.toIso8601String(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Spending by Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1.3,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _showingSections(provider.categoryBreakdown),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLegend(provider.categoryBreakdown),
                const SizedBox(height: 32),
                const Text(
                  'Monthly Budget Status',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildBudgetStatus(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _showingSections(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = _getCategoryColor(data[i]['category']);

      return PieChartSectionData(
        color: color,
        value: data[i]['amount'].toDouble(),
        title: '${data[i]['percentage']}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(List<Map<String, dynamic>> data) {
    return Column(
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getCategoryColor(item['category']),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['category'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                CurrencyFormatter.format(item['amount'].toDouble()),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetStatus(ExpenseProvider provider) {
    final double budget = provider.monthlyBudget; 
    // Use totalExpense because it reflects the sum of expenses for the *filtered* range (which is the selected month)
    // monthTotal coming from backend might be hardcoded to "current month", whereas totalExpense is the sum of the returned expenses.
    final double spent = provider.totalExpense;
    final double percentage = (spent / budget).clamp(0, 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overall Budget (Goal: ${CurrencyFormatter.format(budget)})'),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showBudgetDialog(provider),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text('Used: ${CurrencyFormatter.format(spent)}', style: const TextStyle(fontSize: 12)),
                    Text('${(percentage * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: percentage > 0.8 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 12),
            Text(
              spent > budget 
                  ? 'You are over budget by ${CurrencyFormatter.format(spent - budget)}!'
                  : 'You have ${CurrencyFormatter.format(budget - spent)} left for the month.',
              style: TextStyle(
                color: spent > budget ? Colors.red : Colors.grey.shade600,
                fontSize: 14,
                fontWeight: spent > budget ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetDialog(ExpenseProvider provider) {
    final controller = TextEditingController(text: provider.monthlyBudget.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newBudget = double.tryParse(controller.text);
              if (newBudget != null) {
                provider.setMonthlyBudget(newBudget);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.redAccent;
      case 'transport':
        return Colors.blueAccent;
      case 'shopping':
        return Colors.purpleAccent;
      case 'entertainment':
        return Colors.orangeAccent;
      case 'bills':
        return Colors.greenAccent;
      case 'health':
        return Colors.cyanAccent;
      case 'education':
        return Colors.indigoAccent;
      default:
        return Colors.grey;
    }
  }
}
