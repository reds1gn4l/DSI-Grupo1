import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supply.dart';

class SupplyService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('supplies');

  Stream<List<Supply>> getSupplies() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Supply.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addSupply(Supply supply) async {
    await _collection.add(supply.toMap());
  }

  Future<void> updateSupply(Supply supply) async {
    await _collection.doc(supply.id).update(supply.toMap());
  }

  Future<void> deleteSupply(String id) async {
    await _collection.doc(id).delete();
  }
}