// lib/services/address_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';

class AddressService {
  final String userId; // em breve, isso virá do FirebaseAuth
  AddressService({required this.userId});

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Caminho: addresses/{userId}/user_addresses
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('addresses').doc(userId).collection('user_addresses');

  Stream<List<Address>> getAddresses() {
    return _col
        // Descomente se tiver um campo para ordenação:
        // .orderBy('street')
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  // >>> ORDEM CORRETA: (map, id)
                  .map((d) => Address.fromMap(d.data(), d.id))
                  .toList(),
        );
  }

  Future<Address?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Address.fromMap(doc.data()!, doc.id); // (map, id)
  }

  Future<void> addAddress(Address address) async {
    if (address.id.isEmpty) {
      // novo doc com id auto-gerado
      await _col.add(address.toMap());
    } else {
      // criar/atualizar com id específico
      await _col.doc(address.id).set(address.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> updateAddress(Address address) async {
    // usa merge para não sobrescrever campos acidentalmente
    await _col.doc(address.id).set(address.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteAddress(String addressId) async {
    await _col.doc(addressId).delete();
  }
}
