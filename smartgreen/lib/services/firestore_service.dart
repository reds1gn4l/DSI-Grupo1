import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore users =
      FirebaseFirestore.instance;

  Future<
    String
  >
  addUser(
    User user,
  ) async {
    DocumentReference doc = await users
        .collection(
          'Users',
        )
        .add(
          user.toMap(),
        );
    return doc.id;
  }
}
