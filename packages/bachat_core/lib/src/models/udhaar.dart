class Udhaar {
  final String? id;
  final String type; // 'LENE' or 'DENE'
  final String personName;
  final double amount;
  final DateTime date;
  final String? notes;
  final bool isSettled;

  Udhaar({
    this.id,
    required this.type,
    required this.personName,
    required this.amount,
    required this.date,
    this.notes,
    this.isSettled = false,
  });

  factory Udhaar.fromJson(Map<String, dynamic> json) {
    return Udhaar(
      id: json['_id'],
      type: json['type'],
      personName: json['personName'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      isSettled: json['isSettled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'personName': personName,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'isSettled': isSettled,
    };
  }
}
