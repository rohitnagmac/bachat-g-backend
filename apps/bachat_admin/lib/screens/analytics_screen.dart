import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bachat_core/bachat_core.dart';
import '../providers/admin_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await Provider.of<AdminProvider>(context, listen: false).fetchAnalytics(_days);
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
        actions: [
          DropdownButton<int>(
            value: _days,
            dropdownColor: Colors.white,
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 7, child: Text('Last 7 Days ')),
              DropdownMenuItem(value: 30, child: Text('Last 30 Days ')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _days = val);
                _loadData();
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                    _buildChartCard(
                        'User Growth & Activity',
                        _buildLineChart(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                        'Avg Session Duration (Seconds)',
                        _buildBarChart(),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
        elevation: 4,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AspectRatio(aspectRatio: 1.5, child: chart),
                ],
            ),
        ),
    );
  }

  Widget _buildLineChart() {
    final activeUsers = (_data['activeUsers'] as List<dynamic>?) ?? [];
    final newUsers = (_data['newUsers'] as List<dynamic>?) ?? [];

    // Map dates to spots
    // Assuming backend returns sorted data. we map index 0..N to dates
    // For simplicity, we just plot indices. Robust implementation would parse dates.
    
    List<FlSpot> activeSpots = [];
    List<FlSpot> newSpots = [];

    // Helper to find count for a date index (simplified)
    for (int i = 0; i < activeUsers.length; i++) {
        activeSpots.add(FlSpot(i.toDouble(), (activeUsers[i]['count'] as num).toDouble()));
    }
     for (int i = 0; i < newUsers.length; i++) {
        newSpots.add(FlSpot(i.toDouble(), (newUsers[i]['count'] as num).toDouble()));
    }

    return LineChart(
        LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
                LineChartBarData(
                    spots: activeSpots.isEmpty ? [const FlSpot(0,0)] : activeSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                ),
                 LineChartBarData(
                    spots: newSpots.isEmpty ? [const FlSpot(0,0)] : newSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                ),
            ],
            lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                            return LineTooltipItem(
                                '${spot.barIndex == 0 ? "Active" : "New"}: ${spot.y.toInt()}',
                                const TextStyle(color: Colors.white),
                            );
                        }).toList();
                    }
                )
            )
        )
    );
  }

  Widget _buildBarChart() {
      final sessionData = (_data['avgSessionDuration'] as List<dynamic>?) ?? [];
      List<BarChartGroupData> barGroups = [];

      for (int i = 0; i < sessionData.length; i++) {
          barGroups.add(
              BarChartGroupData(
                  x: i,
                  barRods: [
                      BarChartRodData(
                          toY: (sessionData[i]['avgDuration'] as num).toDouble(),
                          color: Colors.orange,
                          width: 16,
                      )
                  ]
              )
          );
      }

      return BarChart(
          BarChartData(
              barGroups: barGroups,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
          )
      );
  }
}
