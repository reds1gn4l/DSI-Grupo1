import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/order.dart';

class OrderService {
  final String userId;
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  OrderService({required this.userId});

  Future<String> addOrder(Order order) async {
    final docRef = await _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .add(order.toMap());

    return docRef.id;
  }
}
