class Expense {
  final String? id;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}
