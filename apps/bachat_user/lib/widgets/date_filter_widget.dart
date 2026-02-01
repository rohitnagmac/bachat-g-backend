import 'package:flutter/material.dart';

class DateFilterWidget extends StatefulWidget {
  final Function(DateTimeRange?) onDateSelected;

  const DateFilterWidget({super.key, required this.onDateSelected});

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Today',
    'This Week',
    'This Month',
    'Custom'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _handleFilterSelection(filter),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleFilterSelection(String filter) async {
    setState(() {
      _selectedFilter = filter;
    });

    DateTimeRange? range;
    final now = DateTime.now();

    switch (filter) {
      case 'All':
        range = null;
        break;
      case 'Today':
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        range = DateTimeRange(start: startOfDay, end: endOfDay);
        break;
      case 'This Week':
        // Start of week (Monday)
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        range = DateTimeRange(start: startOfWeek, end: endOfDay);
        break;
      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        range = DateTimeRange(start: startOfMonth, end: endOfDay);
        break;
      case 'Custom':
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
          initialDateRange: DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
        );
        if (picked != null) {
          // Ensure the end date covers the full day
          final endOfPicked = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
          range = DateTimeRange(start: picked.start, end: endOfPicked);
        } else {
          setState(() {
            _selectedFilter = 'All';
          });
          range = null;
        }
        break;
    }

    widget.onDateSelected(range);
  }
}
