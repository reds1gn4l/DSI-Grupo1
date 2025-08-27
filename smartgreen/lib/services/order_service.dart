// lib/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/order.dart' as model;

class OrderService {
  final String userId;
  OrderService({required this.userId});

  final fs.FirebaseFirestore _db = fs.FirebaseFirestore.instance;

  Future<String> addOrder(model.Order order) async {
    final doc = await _db
        .collection('orders')
        .doc(userId)
        .collection('user_orders')
        .add(order.toMap());
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
}
