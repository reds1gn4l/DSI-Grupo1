class Supply {
  final String id;
  final String name;
  final int quantity;
  final String validity;
  final DateTime createdAt;
  final String? imageUrl;

  Supply({
    required this.id,
    required this.name,
    required this.quantity,
    required this.validity,
    required this.createdAt,
    this.imageUrl,
  });

  factory Supply.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedCreatedAt = DateTime.now();
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is DateTime) {
      parsedCreatedAt = rawCreatedAt;
    } else if (rawCreatedAt is String) {
      try {
        parsedCreatedAt = DateTime.parse(rawCreatedAt);
      } catch (_) {
        try {
          final parts = rawCreatedAt.split('/');
          if (parts.length == 3) {
            parsedCreatedAt = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }
    } else if (rawCreatedAt != null) {
      try {
        parsedCreatedAt = (rawCreatedAt as dynamic).toDate() as DateTime;
      } catch (_) {}
    }

    return Supply(
      id: id,
      name: data['name'] ?? '',
      quantity:
          (data['quantity'] ?? 0) is int
              ? data['quantity'] as int
              : int.tryParse('${data['quantity']}') ?? 0,
      validity: data['validity'] ?? '',
      createdAt: parsedCreatedAt,
      imageUrl:
          (data['imageUrl'] as String?)?.trim().isEmpty == true
              ? null
              : data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'validity': validity,
      'createdAt': createdAt,
      if (imageUrl != null && imageUrl!.trim().isNotEmpty) 'imageUrl': imageUrl,
    };
  }

  Supply copyWith({
    String? id,
    String? name,
    int? quantity,
    String? validity,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return Supply(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      validity: validity ?? this.validity,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
