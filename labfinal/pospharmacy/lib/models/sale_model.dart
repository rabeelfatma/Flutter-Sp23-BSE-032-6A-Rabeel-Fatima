class SaleModel {
  int? id;
  String datetime; // ISO String
  double amount;
  int synced; // 0 = not synced, 1 = synced

  SaleModel({
    this.id,
    required this.datetime,
    required this.amount,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datetime': datetime,
      'amount': amount,
      'synced': synced,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      datetime: map['datetime'],
      amount: map['amount']?.toDouble() ?? 0.0,
      synced: map['synced'] ?? 0,
    );
  }

  SaleModel copyWith({int? id, String? datetime, double? amount, int? synced}) {
    return SaleModel(
      id: id ?? this.id,
      datetime: datetime ?? this.datetime,
      amount: amount ?? this.amount,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() => 'Sale(id: $id, datetime: $datetime, amount: $amount, synced: $synced)';
}
