import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';

class AddressService {
  final String userId; // em breve, isso virá do FirebaseAuth

  AddressService({required this.userId});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Address>> getAddresses() {
    return _db
        .collection('addresses')
        .doc(userId)
        .collection('user_addresses')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Address.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<void> addAddress(Address address) async {
    await _db
        .collection('addresses')
        .doc(userId)
        .collection('user_addresses')
        .add(address.toMap());
  }

  Future<void> deleteAddress(String addressId) async {
    await _db
        .collection('addresses')
        .doc(userId)
        .collection('user_addresses')
        .doc(addressId)
        .delete();
  }

  Future<void> updateAddress(Address address) async {
    await _db
        .collection('addresses')
        .doc(userId)
        .collection('user_addresses')
        .doc(address.id)
        .update(address.toMap());
  }
}
