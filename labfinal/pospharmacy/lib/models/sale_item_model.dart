class SaleItemModel {
  int? id;
  int saleId; // FK to sale
  int productId; // FK to product
  int quantity;
  double price;

  SaleItemModel({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      quantity: map['quantity'] ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
    );
  }

  SaleItemModel copyWith({int? id, int? saleId, int? productId, int? quantity, double? price}) {
    return SaleItemModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  String toString() => 'SaleItem(id: $id, saleId: $saleId, productId: $productId, quantity: $quantity, price: $price)';
}
