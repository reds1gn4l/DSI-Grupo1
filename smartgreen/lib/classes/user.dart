class User {
  String? id;
  String? name;
  String? email;
  String? address;

  User({this.id, this.name, this.email, this.address});

  // Métodos para salvar e recuperar dados podem ser adicionados aqui
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'address': address};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      address: map['address'],
    );
  }
}
