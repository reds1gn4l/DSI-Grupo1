import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String name;
  final int? temperaturaMin;
  final int? temperaturaMax;
  final int? umidadeMin;
  final int? umidadeMax;
  final DateTime? dataPlantio;
  final String? exposicaoSolar;
  final String status;
  final double? mediaTemperatura;
  final double? mediaUmidade;
  final double? horasLuz;
  final String? imageURL; // Suporta chaves 'imageURL' e 'imageUrl'
  final String? userId; // Já existente e mantido

  Plant({
    required this.id,
    required this.name,
    this.temperaturaMin,
    this.temperaturaMax,
    this.umidadeMin,
    this.umidadeMax,
    this.dataPlantio,
    this.exposicaoSolar,
    required this.status,
    this.mediaTemperatura,
    this.mediaUmidade,
    this.horasLuz,
    this.imageURL, // Adicionado
    this.userId, // Mantido
  });

  factory Plant.fromMap(String id, Map<String, dynamic> data) {
    return Plant(
      id: id,
      name: data['name'] ?? '',
      temperaturaMin: data['temperaturaMin'],
      temperaturaMax: data['temperaturaMax'],
      umidadeMin: data['umidadeMin'],
      umidadeMax: data['umidadeMax'],
      dataPlantio: (data['dataPlantio'] as Timestamp?)?.toDate(),
      exposicaoSolar: data['exposicaoSolar'],
      status: data['status'] ?? 'verde',
      mediaTemperatura: (data['mediaTemperatura'] as num?)?.toDouble(),
      mediaUmidade: (data['mediaUmidade'] as num?)?.toDouble(),
      horasLuz: (data['horasLuz'] as num?)?.toDouble(),
      imageURL: data['imageURL'] ?? data['imageUrl'],
      userId: data['userId'], // Mantido
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'temperaturaMin': temperaturaMin,
      'temperaturaMax': temperaturaMax,
      'umidadeMin': umidadeMin,
      'umidadeMax': umidadeMax,
      'dataPlantio':
          dataPlantio != null ? Timestamp.fromDate(dataPlantio!) : null,
      'exposicaoSolar': exposicaoSolar,
      'status': status,
      'mediaTemperatura': mediaTemperatura,
      'mediaUmidade': mediaUmidade,
      'horasLuz': horasLuz,
      // Persistimos com a chave 'imageUrl' (compatível com dados existentes)
      'imageUrl': imageURL,
      'userId': userId, // Mantido
    };
  }
}
