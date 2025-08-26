import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProduct {
  final String id;
  final String cientificName;
  final DateTime? dataPlantio;
  final String descricaoPlanta;
  final String descricaoProd;
  final String fxTemp;
  final String fxUmidade;
  final double precoUnt;
  final String tempoSol;
  final int? stock;
  final String? category;
  final int? valDias;
  final String imageURL;
  final DateTime? createdAt;

  StoreProduct({
    required this.id,
    required this.cientificName,
    this.dataPlantio,
    required this.descricaoPlanta,
    required this.descricaoProd,
    required this.fxTemp,
    required this.fxUmidade,
    required this.precoUnt,
    required this.tempoSol,
    this.stock,
    this.category,
    this.valDias,
    required this.imageURL,
    this.createdAt,
  });

  factory StoreProduct.fromMap(String id, Map<String, dynamic> map) {
    return StoreProduct(
      id: id,
      cientificName: map['CientificName'] ?? '',
      dataPlantio:
          map['DataPlantio'] != null
              ? DateTime.tryParse(map['DataPlantio'].toString())
              : null,
      descricaoPlanta: map['DescricaoPlanta'] ?? '',
      descricaoProd: map['DescricaoProd'] ?? '',
      fxTemp: map['FxTemp'] ?? '',
      fxUmidade: map['FxUmidade'] ?? '',
      precoUnt: (map['PrecoUnt'] ?? 0).toDouble(),
      tempoSol: map['TempoSol'] ?? '',
      stock: (map['stock'] as num?)?.toInt(),
      category: map['category'],
      valDias: (map['ValDias'] as num?)?.toInt(),
      imageURL: map['imageURL'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'],
    );
  }

  Map<String, dynamic> toMap({bool forUpdate = false}) {
    return {
      'CientificName': cientificName,
      'DataPlantio': dataPlantio?.toIso8601String(),
      'DescricaoPlanta': descricaoPlanta,
      'DescricaoProd': descricaoProd,
      'FxTemp': fxTemp,
      'FxUmidade': fxUmidade,
      'PrecoUnt': precoUnt,
      'TempoSol': tempoSol,
      'stock': stock,
      'category': category,
      'ValDias': valDias,
      'imageURL': imageURL,
      'createdAt': forUpdate ? createdAt : FieldValue.serverTimestamp(),
    };
  }

  StoreProduct copyWith({
    String? id,
    String? cientificName,
    DateTime? dataPlantio,
    String? descricaoPlanta,
    String? descricaoProd,
    String? fxTemp,
    String? fxUmidade,
    double? precoUnt,
    String? tempoSol,
    int? stock,
    String? category,
    int? valDias,
    String? imageURL,
    DateTime? createdAt,
  }) {
    return StoreProduct(
      id: id ?? this.id,
      cientificName: cientificName ?? this.cientificName,
      dataPlantio: dataPlantio ?? this.dataPlantio,
      descricaoPlanta: descricaoPlanta ?? this.descricaoPlanta,
      descricaoProd: descricaoProd ?? this.descricaoProd,
      fxTemp: fxTemp ?? this.fxTemp,
      fxUmidade: fxUmidade ?? this.fxUmidade,
      precoUnt: precoUnt ?? this.precoUnt,
      tempoSol: tempoSol ?? this.tempoSol,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      valDias: valDias ?? this.valDias,
      imageURL: imageURL ?? this.imageURL,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
