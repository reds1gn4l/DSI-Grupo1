import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProduct {
  final String id;
  final String CientificName;
  final DateTime? DataPlantio;
  final String DescricaoPlanta;
  final String DescricaoProd;
  final String FxTemp;
  final String FxUmidade;
  final double PrecoUnt;
  final String TempoSol;
  final int? stock;
  final String? category;
  final int? ValDias;
  final String imageURL;
  final DateTime? createdAt;

  StoreProduct({
    required this.id,
    required this.CientificName,
    this.DataPlantio,
    required this.DescricaoPlanta,
    required this.DescricaoProd,
    required this.FxTemp,
    required this.FxUmidade,
    required this.PrecoUnt,
    required this.TempoSol,
    this.stock,
    this.category,
    this.ValDias,
    required this.imageURL,
    this.createdAt,
  });

  factory StoreProduct.fromMap(
    String id,
    Map<
      String,
      dynamic
    >
    map,
  ) {
    return StoreProduct(
      id:
          id,
      CientificName:
          map['CientificName'] ??
          '',
      DataPlantio:
          map['DataPlantio'] !=
                  null
              ? DateTime.tryParse(
                map['DataPlantio'].toString(),
              )
              : null,
      DescricaoPlanta:
          map['DescricaoPlanta'] ??
          '',
      DescricaoProd:
          map['DescricaoProd'] ??
          '',
      FxTemp:
          map['FxTemp'] ??
          '',
      FxUmidade:
          map['FxUmidade'] ??
          '',
      PrecoUnt:
          (map['PrecoUnt'] ??
                  0)
              .toDouble(),
      TempoSol:
          map['TempoSol'] ??
          '',
      stock:
          (map['stock']
                  as num?)
              ?.toInt(),
      category:
          map['category'],
      ValDias:
          (map['ValDias']
                  as num?)
              ?.toInt(),
      imageURL:
          map['imageURL'] ??
          '',
      createdAt:
          map['createdAt']
                  is Timestamp
              ? (map['createdAt']
                      as Timestamp)
                  .toDate()
              : map['createdAt'],
    );
  }

  Map<
    String,
    dynamic
  >
  toMap({
    bool forUpdate =
        false,
  }) {
    return {
      'CientificName':
          CientificName,
      'DataPlantio':
          DataPlantio?.toIso8601String(),
      'DescricaoPlanta':
          DescricaoPlanta,
      'DescricaoProd':
          DescricaoProd,
      'FxTemp':
          FxTemp,
      'FxUmidade':
          FxUmidade,
      'PrecoUnt':
          PrecoUnt,
      'TempoSol':
          TempoSol,
      'stock':
          stock,
      'category':
          category,
      'ValDias':
          ValDias,
      'imageURL':
          imageURL,
      'createdAt':
          forUpdate
              ? createdAt
              : FieldValue.serverTimestamp(),
    };
  }

  StoreProduct copyWith({
    String? id,
    String? CientificName,
    DateTime? DataPlantio,
    String? DescricaoPlanta,
    String? DescricaoProd,
    String? FxTemp,
    String? FxUmidade,
    double? PrecoUnt,
    String? TempoSol,
    int? stock,
    String? category,
    int? ValDias,
    String? imageURL,
    DateTime? createdAt,
  }) {
    return StoreProduct(
      id:
          id ??
          this.id,
      CientificName:
          CientificName ??
          this.CientificName,
      DataPlantio:
          DataPlantio ??
          this.DataPlantio,
      DescricaoPlanta:
          DescricaoPlanta ??
          this.DescricaoPlanta,
      DescricaoProd:
          DescricaoProd ??
          this.DescricaoProd,
      FxTemp:
          FxTemp ??
          this.FxTemp,
      FxUmidade:
          FxUmidade ??
          this.FxUmidade,
      PrecoUnt:
          PrecoUnt ??
          this.PrecoUnt,
      TempoSol:
          TempoSol ??
          this.TempoSol,
      stock:
          stock ??
          this.stock,
      category:
          category ??
          this.category,
      ValDias:
          ValDias ??
          this.ValDias,
      imageURL:
          imageURL ??
          this.imageURL,
      createdAt:
          createdAt ??
          this.createdAt,
    );
  }
}
