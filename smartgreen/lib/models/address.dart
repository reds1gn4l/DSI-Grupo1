// lib/models/address.dart
class Address {
  final String id;

  // Principais
  final String cep;
  final String state; // UF
  final String city;
  final String neighborhood; // Bairro
  final String street;
  final String number; // “SN” quando não houver

  // Opcionais
  final String complement;
  final String reference;

  // Geolocalização (opcional)
  final double? lat;
  final double? lng;

  Address({
    required this.id,
    this.cep = '',
    this.state = '',
    this.city = '',
    this.neighborhood = '',
    this.street = '',
    this.number = '',
    this.complement = '',
    this.reference = '',
    this.lat,
    this.lng,
  });

  Address copyWith({
    String? id,
    String? cep,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
    String? reference,
    double? lat,
    double? lng,
  }) {
    return Address(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      state: state ?? this.state,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      reference: reference ?? this.reference,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      cep: (map['cep'] ?? '') as String,
      state: (map['state'] ?? '') as String,
      city: (map['city'] ?? '') as String,
      neighborhood: (map['neighborhood'] ?? '') as String,
      street: (map['street'] ?? '') as String,
      number: (map['number'] ?? '') as String,
      complement: (map['complement'] ?? '') as String,
      reference: (map['reference'] ?? '') as String,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'state': state,
      'city': city,
      'neighborhood': neighborhood,
      'street': street,
      'number': number,
      'complement': complement,
      'reference': reference,
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  String toString() {
    final p1 = [street, number].where((e) => e.isNotEmpty).join(', ');
    final p2 = [
      neighborhood,
      city,
      state,
    ].where((e) => e.isNotEmpty).join(' - ');
    final p3 = cep.isNotEmpty ? ' • CEP: $cep' : '';
    return [p1, p2].where((e) => e.isNotEmpty).join(' | ') + p3;
  }
}
