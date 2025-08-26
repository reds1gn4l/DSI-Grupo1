import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProduct {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final int? stock;
  final String? category;
  final String? imageUrl;
  final DateTime? createdAt;

  StoreProduct({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.stock,
    this.category,
    this.imageUrl,
    this.createdAt,
  });

  factory StoreProduct.fromMap(String id, Map<String, dynamic> map) {
    return StoreProduct(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      price:
          (map['price'] is int)
              ? (map['price'] as int).toDouble()
              : (map['price'] as num?)?.toDouble(),
      stock: (map['stock'] as num?)?.toInt(),
      category: map['category'],
      imageUrl: map['imageUrl'],
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'],
    );
  }

  Map<String, dynamic> toMap({bool forUpdate = false}) {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': forUpdate ? createdAt : FieldValue.serverTimestamp(),
    };
  }

  StoreProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return StoreProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
