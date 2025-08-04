class Supply {
  final String id;
  final String name;
  final int quantity;
  final String validity;

  Supply({
    required this.id,
    required this.name,
    required this.quantity,
    required this.validity,
  });

  factory Supply.fromMap(String id, Map<String, dynamic> data) {
    return Supply(
      id: id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      validity: data['validity'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'validity': validity,
    };
  }
}