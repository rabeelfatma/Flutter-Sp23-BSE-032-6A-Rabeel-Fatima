class LedgerModel {
  int? id;
  String description;
  double amount;
  String date;
  String type; // debit or credit

  LedgerModel({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.type = 'debit',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date,
      'type': type,
    };
  }

  factory LedgerModel.fromMap(Map<String, dynamic> map) {
    return LedgerModel(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: map['date'],
      type: map['type'] ?? 'debit',
    );
  }
}
