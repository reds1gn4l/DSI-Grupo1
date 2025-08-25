import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {'product': product.toMap(), 'quantity': quantity};
  }

  Map<String, dynamic> toOrderMap() {
    return {
      'produtoRef': FirebaseFirestore.instance
          .collection('produtos')
          .doc(product.id),
      'quantidade': quantity,
      'precoVenda': product.price,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      product: Product.fromMap('', data['product']),
      quantity: data['quantity'] ?? 1,
    );
  }

  static Future<CartItem> fromOrderMapAsync(Map<String, dynamic> data) async {
    final DocumentReference produtoRef = data['produtoRef'];
    final int quantidade = data['quantidade'] ?? 1;
    final double precoVenda = (data['precoVenda'] ?? 0).toDouble();

    final produtoSnapshot = await produtoRef.get();
    final produtoData = produtoSnapshot.data() as Map<String, dynamic>;

    final produto = Product.fromMap(
      produtoRef.id,
      produtoData,
    ).copyWith(price: precoVenda);

    return CartItem(product: produto, quantity: quantidade);
  }
}
