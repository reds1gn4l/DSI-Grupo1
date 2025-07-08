import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/order.dart';

class OrderService {
  final String userId;
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  OrderService({required this.userId});

  Future<void> addOrder(Order order) async {
    await _db.collection('orders').add(order.toMap());
  }
}
