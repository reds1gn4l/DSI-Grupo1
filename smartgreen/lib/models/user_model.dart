import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  String? id;
  String name;
  String email;
  String? address;
  String password; // armazenado como hash
  bool isAdmin;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.address,
    this.isAdmin =
        false,
  });

  Map<
    String,
    dynamic
  >
  toMap() {
    return {
      if (id !=
          null)
        'id':
            id,
      'name':
          name,
      'email':
          email,
      'address':
          address,
      'pass':
          password,
      'isAdmin':
          isAdmin,
    };
  }

  factory User.fromMap(
    Map<
      String,
      dynamic
    >
    map,
  ) {
    return User(
      id:
          map['id'],
      name:
          map['name'],
      email:
          map['email'],
      address:
          map['address'],
      password:
          map['pass'] ??
          '',
      isAdmin:
          map['isAdmin'],
    );
  }

  // Cria User com senha em md5
  factory User.withMd5({
    required String name,
    required String email,
    required String password,
    bool isAdmin =
        false,
    String? address,
    String? id,
  }) {
    final bytes = utf8.encode(
      password,
    );
    final hash =
        md5
            .convert(
              bytes,
            )
            .toString();
    return User(
      id:
          id,
      name:
          name,
      email:
          email,
      password:
          hash,
      address:
          address,
      isAdmin:
          isAdmin,
    );
  }
}
