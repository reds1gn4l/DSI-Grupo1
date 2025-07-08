import 'classes/user.dart';

User? currentUser;

// Exemplo de como salvar dados no objeto User
dynamic saveUserData({
  String? id,
  String? name,
  String? email,
  String? address,
}) {
  currentUser = User(id: id, name: name, email: email, address: address);
}

// Exemplo de como acessar os dados do usuário atual
dynamic getUserData() {
  return currentUser;
}
