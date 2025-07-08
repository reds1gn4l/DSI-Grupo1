import 'cart_item.dart';
import 'address.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final Address address;
  final String paymentMethod;
  final double total;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'address': address.toMap(),
      'paymentMethod': paymentMethod,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> data) {
    return Order(
      id: id,
      items:
          (data['items'] as List)
              .map((item) => CartItem.fromMap(item))
              .toList(),
      address: Address.fromMap('', data['address']),
      paymentMethod: data['paymentMethod'],
      total: (data['total'] ?? 0).toDouble(),
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}
