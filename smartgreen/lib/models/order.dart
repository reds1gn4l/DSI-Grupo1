// lib/models/order.dart
import 'order_item.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final String addressId; // <- só referência ao endereço
  final String paymentMethod;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    required this.addressId,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'items': items.map((e) => e.toMap()).toList(),
    'addressId': addressId,
    'paymentMethod': paymentMethod,
    'total': total,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Order.fromMap(String id, Map<String, dynamic> data) {
    final itemsData = (data['items'] as List?) ?? const [];
    return Order(
      id: id,
      items:
          itemsData
              .whereType<Map<String, dynamic>>()
              .map(OrderItem.fromMap)
              .toList(),
      addressId: (data['addressId'] ?? '') as String,
      paymentMethod: (data['paymentMethod'] ?? '') as String,
      total: (data['total'] is num) ? (data['total'] as num).toDouble() : 0.0,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
