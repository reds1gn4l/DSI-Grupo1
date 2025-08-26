import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.precoUnt * quantity;

  Map<String, dynamic> toMap() {
    return {'product': product.toMap(), 'quantity': quantity};
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      product: Product.fromMap('', data['product']),
      quantity: data['quantity'] ?? 1,
    );
  }
}
