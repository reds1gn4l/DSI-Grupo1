import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_product.dart';

class StoreProductService {
  final _col = FirebaseFirestore.instance.collection('products');

  Stream<List<StoreProduct>> stream({String? search}) {
    // Não ordena por 'name', pois não existe mais. Pode ordenar por CientificName se necessário.
    final q = _col.orderBy('CientificName');
    return q.snapshots().map((snap) {
      final items =
          snap.docs.map((d) => StoreProduct.fromMap(d.id, d.data())).toList();
      if (search == null || search.trim().isEmpty) return items;
      final s = search.toLowerCase().trim();
      return items
          .where((p) => p.cientificName.toLowerCase().contains(s))
          .toList();
    });
  }

  Future<StoreProduct?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return StoreProduct.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<String> create(StoreProduct p) async {
    final data = p.copyWith(id: '').toMap();
    final ref = await _col.add(data);
    return ref.id;
  }

  Future<void> update(StoreProduct p) async {
    if (p.id.isEmpty) throw ArgumentError('id vazio no update');
    await _col.doc(p.id).update(p.toMap(forUpdate: true));
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<List<StoreProduct>> searchByCategoryAndQuery({
    required String category,
    required String query,
    int limit = 8,
  }) async {
    final term = query.trim();
    if (term.length < 3) return <StoreProduct>[];

    // Firestore prefix search usando orderBy + startAt/endAt em 'CientificName'.
    // Observação: a comparação é case-sensitive conforme armazenado.
    try {
      // Busca e ordenação apenas pelo nome da planta ('Nome').
      final q = _col
          .where('category', isEqualTo: category)
          .orderBy('Nome')
          .startAt([term])
          .endAt(["$term\uf8ff"]).limit(limit);
      final snap = await q.get();
      return snap.docs
          .map((d) => StoreProduct.fromMap(d.id, d.data()))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        // Fallback sem índice composto: busca por categoria e filtra no cliente somente por Nome
        final snap = await _col.where('category', isEqualTo: category).get();
        final termLower = term.toLowerCase();
        final filtered = snap.docs
            .map((d) => StoreProduct.fromMap(d.id, d.data()))
            .where((p) => p.nome.toLowerCase().startsWith(termLower) ||
                p.nome.toLowerCase().contains(termLower))
            .toList();
        filtered.sort((a, b) => a.nome.compareTo(b.nome));
        return filtered.length > limit ? filtered.sublist(0, limit) : filtered;
      }
      rethrow;
    }
  }
}
