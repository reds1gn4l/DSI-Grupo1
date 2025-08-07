class Plant {
  final String id;
  final String name;
  final String status;
  final int? temperaturaMin;
  final int? temperaturaMax;
  final int? umidadeMin;
  final int? umidadeMax;
  final String? plantingDate;
  final String? lightPreference;

  Plant({
    required this.id,
    required this.name,
    required this.status,
    this.temperaturaMin,
    this.temperaturaMax,
    this.umidadeMin,
    this.umidadeMax,
    this.plantingDate,
    this.lightPreference,
  });

  factory Plant.fromMap(String id, Map<String, dynamic> data) {
    return Plant(
      id: id,
      name: data['name'] ?? '',
      status: data['status'] ?? 'cinza',
      temperaturaMin: data['temperaturaMin'],
      temperaturaMax: data['temperaturaMax'],
      umidadeMin: data['umidadeMin'],
      umidadeMax: data['umidadeMax'],
      plantingDate: data['plantingDate'],
      lightPreference: data['lightPreference'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'temperaturaMin': temperaturaMin,
      'temperaturaMax': temperaturaMax,
      'umidadeMin': umidadeMin,
      'umidadeMax': umidadeMax,
      'plantingDate': plantingDate,
      'lightPreference': lightPreference,
    };
  }
}
