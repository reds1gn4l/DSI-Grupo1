import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProduct {
  final String id;
  final String nome;
  final String cientificName;
  final DateTime? dataPlantio;
  final String descricaoPlanta;
  final String descricaoProd;
  final String fxTemp;
  final String fxUmidade;
  final double? temperaturaMax;
  final double? temperaturaMin;
  final double? umidadeMax;
  final double? umidadeMinima;
  final double precoUnt;
  final String tempoSol;
  final int? stock;
  final String? category;
  final int? valDias;
  final String imageURL;
  final DateTime? createdAt;

  StoreProduct({
    required this.id,
    required this.nome,
    required this.cientificName,
    this.dataPlantio,
    required this.descricaoPlanta,
    required this.descricaoProd,
    required this.fxTemp,
    required this.fxUmidade,
    this.temperaturaMax,
    this.temperaturaMin,
    this.umidadeMax,
    this.umidadeMinima,
    required this.precoUnt,
    required this.tempoSol,
    this.stock,
    this.category,
    this.valDias,
    required this.imageURL,
    this.createdAt,
  });

  factory StoreProduct.fromMap(
    String id,
    Map<
      String,
      dynamic
    >
    data,
  ) {
    return StoreProduct(
      id:
          id,
      nome:
          data['Nome'] ??
          '',
      cientificName:
          data['CientificName'] ??
          '',
      dataPlantio:
          data['DataPlantio'] !=
                  null
              ? DateTime.tryParse(
                data['DataPlantio'].toString(),
              )
              : null,
      descricaoPlanta:
          data['DescricaoPlanta'] ??
          data['descricaoPlanta'] ??
          data['descricao_planta'] ??
          '',
      descricaoProd:
          data['DescricaoProd'] ??
          data['descricaoProd'] ??
          data['descricao_prod'] ??
          '',
      fxTemp:
          data['FxTemp'] ??
          data['fxTemp'] ??
          data['fx_temp'] ??
          '',
      fxUmidade:
          data['FxUmidade'] ??
          data['fxUmidade'] ??
          data['fx_umidade'] ??
          '',
      temperaturaMax:
          (data['temperaturaMax'] ??
                      data['temperatura_max']) !=
                  null
              ? (data['temperaturaMax'] ??
                      data['temperatura_max'])
                  .toDouble()
              : null,
      temperaturaMin:
          (data['temperaturaMin'] ??
                      data['temperatura_min']) !=
                  null
              ? (data['temperaturaMin'] ??
                      data['temperatura_min'])
                  .toDouble()
              : null,
      umidadeMax:
          (data['umidadeMax'] ??
                      data['umidade_max']) !=
                  null
              ? (data['umidadeMax'] ??
                      data['umidade_max'])
                  .toDouble()
              : null,
      umidadeMinima:
          (data['umidadeMinima'] ??
                      data['umidade_minima']) !=
                  null
              ? (data['umidadeMinima'] ??
                      data['umidade_minima'])
                  .toDouble()
              : null,
      precoUnt: StoreProduct._parsePrecoUnt(
        data['PrecoUnt'] ??
            data['precoUnt'] ??
            data['preco_unt'],
      ),
      tempoSol:
          data['TempoSol'] ??
          data['tempoSol'] ??
          data['tempo_sol'] ??
          '',
      stock:
          (data['stock']
                  as num?)
              ?.toInt(),
      category:
          data['category'],
      valDias:
          (data['ValDias'] ??
                      data['valDias'] ??
                      data['val_dias'])
                  is num
              ? ((data['ValDias'] ??
                          data['valDias'] ??
                          data['val_dias'])
                      as num?)
                  ?.toInt()
              : int.tryParse(
                (data['ValDias'] ??
                            data['valDias'] ??
                            data['val_dias'])
                        ?.toString() ??
                    '',
              ),
      imageURL:
          data['imageURL'] ??
          data['imageUrl'] ??
          data['image_url'] ??
          '',
      createdAt:
          data['createdAt']
                  is Timestamp
              ? (data['createdAt']
                      as Timestamp)
                  .toDate()
              : data['createdAt'],
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
      'Nome':
          nome,
      'CientificName':
          cientificName,
      'DataPlantio':
          dataPlantio?.toIso8601String(),
      'DescricaoPlanta':
          descricaoPlanta,
      'DescricaoProd':
          descricaoProd,
      'FxTemp':
          fxTemp,
      'FxUmidade':
          fxUmidade,
      'temperaturaMax':
          temperaturaMax,
      'temperaturaMin':
          temperaturaMin,
      'umidadeMax':
          umidadeMax,
      'umidadeMinima':
          umidadeMinima,
      'PrecoUnt':
          precoUnt,
      'TempoSol':
          tempoSol,
      'stock':
          stock,
      'category':
          category,
      'ValDias':
          valDias,
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
    String? nome,
    String? cientificName,
    DateTime? dataPlantio,
    String? descricaoPlanta,
    String? descricaoProd,
    String? fxTemp,
    String? fxUmidade,
    double? temperaturaMax,
    double? temperaturaMin,
    double? umidadeMax,
    double? umidadeMinima,
    double? precoUnt,
    String? tempoSol,
    int? stock,
    String? category,
    int? valDias,
    String? imageURL,
    DateTime? createdAt,
  }) {
    return StoreProduct(
      id:
          id ??
          this.id,
      nome:
          nome ??
          this.nome,
      cientificName:
          cientificName ??
          this.cientificName,
      dataPlantio:
          dataPlantio ??
          this.dataPlantio,
      descricaoPlanta:
          descricaoPlanta ??
          this.descricaoPlanta,
      descricaoProd:
          descricaoProd ??
          this.descricaoProd,
      fxTemp:
          fxTemp ??
          this.fxTemp,
      fxUmidade:
          fxUmidade ??
          this.fxUmidade,
      temperaturaMax:
          temperaturaMax ??
          this.temperaturaMax,
      temperaturaMin:
          temperaturaMin ??
          this.temperaturaMin,
      umidadeMax:
          umidadeMax ??
          this.umidadeMax,
      umidadeMinima:
          umidadeMinima ??
          this.umidadeMinima,
      precoUnt:
          precoUnt ??
          this.precoUnt,
      tempoSol:
          tempoSol ??
          this.tempoSol,
      stock:
          stock ??
          this.stock,
      category:
          category ??
          this.category,
      valDias:
          valDias ??
          this.valDias,
      imageURL:
          imageURL ??
          this.imageURL,
      createdAt:
          createdAt ??
          this.createdAt,
    );
  }

  static double _parsePrecoUnt(
    dynamic value,
  ) {
    if (value ==
        null)
      return 0.0;
    if (value
        is num)
      return value.toDouble();
    if (value
        is String)
      return double.tryParse(
            value.replaceAll(
              ',',
              '.',
            ),
          ) ??
          0.0;
    return 0.0;
  }
}
