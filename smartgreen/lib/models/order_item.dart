// lib/models/order_item.dart
class OrderItem {
  final String productId;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };

  factory OrderItem.fromMap(Map<String, dynamic> data) => OrderItem(
    productId: (data['productId'] ?? '') as String,
    quantity: (data['quantity'] ?? 0) as int,
    unitPrice:
        (data['unitPrice'] is num)
            ? (data['unitPrice'] as num).toDouble()
            : 0.0,
  );
}
