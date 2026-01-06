class CustomerModel {
  int? id;
  String name;
  String email;
  String phone;

  CustomerModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  CustomerModel copyWith({int? id, String? name, String? email, String? phone}) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() => 'Customer(id: $id, name: $name, email: $email, phone: $phone)';
}
