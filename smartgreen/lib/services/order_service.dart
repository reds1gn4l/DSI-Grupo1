import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:intl/intl.dart';

import '../models/order.dart' as model;
import '../models/supply.dart';
import '../models/store_product.dart';
import 'store_product_service.dart';
import 'supply_service.dart';

class OrderService {
  final String userId;
  OrderService({required this.userId});

  final fs.FirebaseFirestore _db = fs.FirebaseFirestore.instance;
  final StoreProductService _productService = StoreProductService();
  final SupplyService _supplyService = SupplyService();

  Future<String> addOrder(model.Order order) async {
    final doc = await _db
        .collection('orders')
        .doc(userId)
        .collection('user_orders')
        .add(order.toMap());

    try {
      await _addSuppliesFromOrder(order);
    } catch (e) {}

    return doc.id;
  }

  Stream<model.Order> watchOrder(String orderId) {
    return _db
        .collection('orders')
        .doc(userId)
        .collection('user_orders')
        .doc(orderId)
        .snapshots()
        .map((snap) => model.Order.fromMap(snap.id, snap.data() ?? {}));
  }

  Future<void> _addSuppliesFromOrder(model.Order order) async {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');

    for (final it in order.items) {
      StoreProduct? product;
      try {
        product = await _productService.getById(it.productId);
      } catch (_) {
        product = null;
      }

      final String nome =
          (product?.cientificName.trim().isNotEmpty ?? false)
              ? product!.cientificName
              : 'Produto';

      final int qty = it.quantity;

      String validity = '';
      final int? valDias = product?.valDias;
      if (valDias != null && valDias > 0) {
        final v = now.add(Duration(days: valDias));
        validity = formatter.format(v);
      }

      final supply = Supply(
        id: '',
        name: nome,
        quantity: qty,
        validity: validity,
        createdAt: now,
        imageUrl:
            (product?.imageURL.trim().isNotEmpty ?? false)
                ? product!.imageURL
                : null,
      );

      await _supplyService.addSupply(supply);
    }
  }
}
