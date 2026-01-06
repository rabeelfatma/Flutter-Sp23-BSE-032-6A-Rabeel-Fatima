class ProductModel {
  int? id;
  String name;
  double price;
  int stock;
  int synced; // 0 = not synced, 1 = synced

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.synced = 0,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'synced': synced,
    };
  }

  // Convert from SQLite Map to ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      price: map['price']?.toDouble() ?? 0.0,
      stock: map['stock'] ?? 0,
      synced: map['synced'] ?? 0,
    );
  }

  // Copy for updates
  ProductModel copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    int? synced,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price, stock: $stock, synced: $synced)';
}
