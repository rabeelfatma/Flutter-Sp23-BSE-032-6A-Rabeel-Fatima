class ProductModel {
  int? id;
  String sku;
  String name;
  double price;
  double cost;
  String category;
  int stock;
  int synced; // 0 = not synced, 1 = synced

  ProductModel({
    this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.cost,
    required this.category,
    required this.stock,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'price': price,
      'cost': cost,
      'category': category,
      'stock': stock,
      'synced': synced,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      cost: map['cost']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      synced: map['synced'] ?? 0,
    );
  }

  ProductModel copyWith({
    int? id,
    String? sku,
    String? name,
    double? price,
    double? cost,
    String? category,
    int? stock,
    int? synced,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, sku: $sku, name: $name, price: $price, cost: $cost, category: $category, stock: $stock, synced: $synced)';
  }
}
