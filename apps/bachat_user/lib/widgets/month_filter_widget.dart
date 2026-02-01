import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthFilterWidget extends StatefulWidget {
  final Function(DateTimeRange) onMonthSelected;

  const MonthFilterWidget({super.key, required this.onMonthSelected});

  @override
  State<MonthFilterWidget> createState() => _MonthFilterWidgetState();
}

class _MonthFilterWidgetState extends State<MonthFilterWidget> {
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Ensure we start at the beginning of the month to avoid day overflow issues
    // e.g. if today is 31st and we go to Feb, we don't want strict date math to fail
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChange();
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);
    });
    
    _notifyChange();
  }

  void _notifyChange() {
    // Start: 1st of the month at 00:00:00
    final start = DateTime(_currentMonth.year, _currentMonth.month, 1);
    
    // End: Last day of the month at 23:59:59
    // Move to next month 1st day, subtract 1 second (or 1 day + set time)
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final end = nextMonth.subtract(const Duration(seconds: 1));

    widget.onMonthSelected(DateTimeRange(start: start, end: end));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('MMMM yyyy').format(_currentMonth),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
            // Optional: Disable future months if desired, but user requirements didn't specify
            // onPressed: _currentMonth.isBefore(DateTime(DateTime.now().year, DateTime.now().month)) 
            // ? () => _changeMonth(1) 
            // : null,
          ),
        ],
      ),
    );
  }
}
