class Address {
  final String id;
  final String street;
  final String cep;
  final String city;
  final String complement;

  Address({
    required this.id,
    required this.street,
    required this.cep,
    required this.city,
    required this.complement,
  });

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'cep': cep,
      'city': city,
      'complement': complement,
    };
  }

  factory Address.fromMap(String id, Map<String, dynamic> data) {
    return Address(
      id: id,
      street: data['street'] ?? '',
      cep: data['cep'] ?? '',
      city: data['city'] ?? '',
      complement: data['complement'] ?? '',
    );
  }
}
