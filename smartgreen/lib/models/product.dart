class Product {
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

  Product({
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
  });

  factory Product.fromMap(
    String id,
    Map<
      String,
      dynamic
    >
    data,
  ) {
    return Product(
      id:
          id,
      CientificName:
          data['CientificName'] ??
          '',
      DataPlantio:
          data['DataPlantio'] !=
                  null
              ? DateTime.tryParse(
                data['DataPlantio'].toString(),
              )
              : null,
      DescricaoPlanta:
          data['DescricaoPlanta'] ??
          '',
      DescricaoProd:
          data['DescricaoProd'] ??
          '',
      FxTemp:
          data['FxTemp'] ??
          '',
      FxUmidade:
          data['FxUmidade'] ??
          '',
      PrecoUnt:
          (data['PrecoUnt'] ??
                  0)
              .toDouble(),
      TempoSol:
          data['TempoSol'] ??
          '',
      stock:
          (data['stock']
                  as num?)
              ?.toInt(),
      category:
          data['category'],
      ValDias:
          (data['ValDias']
                  as num?)
              ?.toInt(),
      imageURL:
          data['imageURL'] ??
          '',
    );
  }

  Map<
    String,
    dynamic
  >
  toMap() {
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
    };
  }
}
