class LedgerModel {
  int? id;
  String description;
  double amount;
  String date; // ISO string
  String type; // "debit" or "credit"

  LedgerModel({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.type = 'debit', // default to debit
  });

  /// Create LedgerModel from Map (DB row)
  factory LedgerModel.fromMap(Map<String, dynamic> map) {
    return LedgerModel(
      id: map['id'],
      description: map['description'],
      amount: map['amount']?.toDouble() ?? 0.0,
      date: map['date'],
      type: map['type'] ?? 'debit',
    );
  }

  /// Convert LedgerModel to Map (for DB insertion/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date,
      'type': type,
    };
  }

  /// Copy with optional new values
  LedgerModel copyWith({
    int? id,
    String? description,
    double? amount,
    String? date,
    String? type,
  }) {
    return LedgerModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'Ledger(id: $id, description: $description, amount: $amount, date: $date, type: $type)';
}
