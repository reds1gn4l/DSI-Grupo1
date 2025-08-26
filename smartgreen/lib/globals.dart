import 'package:smartgreen/models/user_model.dart';

User?
currentUser;

// Exemplo de como salvar dados no objeto User
dynamic
saveUserData({
  String? id,
  String? name,
  String? email,
  String? address,
  required isAdmin,
}) {
  currentUser = User(
    id:
        id,
    name:
        name ??
        '',
    email:
        email ??
        '',
    address:
        address,
    password:
        '',
    isAdmin:
        isAdmin ??
        false,
  );
}

// Exemplo de como acessar os dados do usuário atual
dynamic
getUserData() {
  return currentUser;
}
