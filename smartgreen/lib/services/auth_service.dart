import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'Users',
  );

  String md5Hash(
    String input,
  ) {
    return md5
        .convert(
          utf8.encode(
            input,
          ),
        )
        .toString();
  }

  Future<
    Map<
      String,
      dynamic
    >?
  >
  login(
    String email,
    String password,
  ) async {
    // ...existing code...

    final hashedPassword = md5Hash(
      password,
    );
    final result =
        await users
            .where(
              'email',
              isEqualTo:
                  email.trim(),
            )
            .where(
              'pass',
              isEqualTo:
                  hashedPassword,
            )
            .get();

    if (result.docs.isNotEmpty) {
      final doc =
          result.docs.first;
      final data =
          doc.data()
              as Map<
                String,
                dynamic
              >;
      return {
        'id':
            doc.id,
        'name':
            data['name'],
        'email':
            data['email'],
        'address':
            data['address'],
        'isAdmin':
            data['isAdmin'],
      };
    }
    return null;
  }
}
