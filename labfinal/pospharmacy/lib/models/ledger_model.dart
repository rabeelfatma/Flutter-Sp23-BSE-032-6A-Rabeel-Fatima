class LedgerModel {
  int? id;
  String description;
  double amount;
  String date; // ISO string

  LedgerModel({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory LedgerModel.fromMap(Map<String, dynamic> map) {
    return LedgerModel(
      id: map['id'],
      description: map['description'],
      amount: map['amount']?.toDouble() ?? 0.0,
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date,
    };
  }

  LedgerModel copyWith({int? id, String? description, double? amount, String? date}) {
    return LedgerModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  @override
  String toString() => 'Ledger(id: $id, description: $description, amount: $amount, date: $date)';
}
