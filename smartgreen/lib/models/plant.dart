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

  // Novos campos para detalhamento
  final double? mediaTemperatura;
  final double? mediaUmidade;
  final double? horasLuz;

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
  });

  factory Plant.fromMap(String id, Map<String, dynamic> map) {
    return Plant(
      id: id,
      name: map['name'] ?? '',
      temperaturaMin: map['temperaturaMin'],
      temperaturaMax: map['temperaturaMax'],
      umidadeMin: map['umidadeMin'],
      umidadeMax: map['umidadeMax'],
      dataPlantio: (map['dataPlantio'] as Timestamp?)?.toDate(),
      exposicaoSolar: map['exposicaoSolar'],
      status: map['status'] ?? 'cinza',
      mediaTemperatura: (map['mediaTemperatura'] as num?)?.toDouble(),
      mediaUmidade: (map['mediaUmidade'] as num?)?.toDouble(),
      horasLuz: (map['horasLuz'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'temperaturaMin': temperaturaMin,
      'temperaturaMax': temperaturaMax,
      'umidadeMin': umidadeMin,
      'umidadeMax': umidadeMax,
      'dataPlantio': dataPlantio,
      'exposicaoSolar': exposicaoSolar,
      'status': status,
      'mediaTemperatura': mediaTemperatura,
      'mediaUmidade': mediaUmidade,
      'horasLuz': horasLuz,
    };
  }
}
