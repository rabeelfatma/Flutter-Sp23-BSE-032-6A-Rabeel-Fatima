class SaleModel {
  int? id;
  String datetime; // ISO String
  double amount;
  int customerId; // optional: link to customer
  int synced; // 0 = not synced, 1 = synced

  SaleModel({
    this.id,
    required this.datetime,
    required this.amount,
    this.customerId = 0,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datetime': datetime,
      'amount': amount,
      'customer_id': customerId,
      'synced': synced,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      datetime: map['datetime'],
      amount: map['amount']?.toDouble() ?? 0.0,
      customerId: map['customer_id'] ?? 0,
      synced: map['synced'] ?? 0,
    );
  }

  SaleModel copyWith({int? id, String? datetime, double? amount, int? customerId, int? synced}) {
    return SaleModel(
      id: id ?? this.id,
      datetime: datetime ?? this.datetime,
      amount: amount ?? this.amount,
      customerId: customerId ?? this.customerId,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() => 'Sale(id: $id, datetime: $datetime, amount: $amount, customerId: $customerId, synced: $synced)';
}
