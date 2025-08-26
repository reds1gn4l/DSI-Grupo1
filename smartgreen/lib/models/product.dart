class Product {
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

  Product({
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
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      cientificName: data['CientificName'] ?? '',
      dataPlantio:
          data['DataPlantio'] != null
              ? DateTime.tryParse(data['DataPlantio'].toString())
              : null,
      descricaoPlanta: data['DescricaoPlanta'] ?? '',
      descricaoProd: data['DescricaoProd'] ?? '',
      fxTemp: data['FxTemp'] ?? '',
      fxUmidade: data['FxUmidade'] ?? '',
      precoUnt: (data['PrecoUnt'] ?? 0).toDouble(),
      tempoSol: data['TempoSol'] ?? '',
      stock: (data['stock'] as num?)?.toInt(),
      category: data['category'],
      valDias: (data['ValDias'] as num?)?.toInt(),
      imageURL: data['imageURL'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
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
    };
  }
}
