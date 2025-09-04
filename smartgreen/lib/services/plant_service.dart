import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../globals.dart';
import '../models/plant.dart';

class PlantService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Plant>> getPlants() {
    return _db.collection('plants').snapshots().map((snap) {
      final plants =
          snap.docs.map((doc) => Plant.fromMap(doc.id, doc.data())).toList();
      plants.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return plants;
    });
  }

  Stream<List<Plant>> getPlantsByUser(String userId) {
    return _db
        .collection('plants')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final plants =
          snap.docs.map((doc) => Plant.fromMap(doc.id, doc.data())).toList();
      plants.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return plants;
    });
  }

  Future<List<Plant>> getAllPlants() async {
    final snap = await _db.collection('plants').get();

    final plants =
        snap.docs.map((doc) => Plant.fromMap(doc.id, doc.data())).toList();
    plants.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return plants;
  }

  Future<List<Plant>> getAllPlantsByUser(String userId) async {
    final snap = await _db
        .collection('plants')
        .where('userId', isEqualTo: userId)
        .get();

    final plants =
        snap.docs.map((doc) => Plant.fromMap(doc.id, doc.data())).toList();
    plants.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return plants;
  }

  Future<Plant> fetchPlantById(String id) async {
    final doc = await _db.collection('plants').doc(id).get();
    if (!doc.exists) {
      throw Exception('Planta não encontrada');
    }
    return Plant.fromMap(doc.id, doc.data()!);
  }

  Future<void> createPlant(Plant plant) async {
    try {
      final uid = plant.userId ?? currentUser?.id;
      final data = plant.userId == null ? plant.copyWith(userId: uid) : plant;
      if (data.userId == null || data.userId!.isEmpty) {
        throw Exception('Usuário não autenticado para salvar a planta');
      }
      await _db.collection('plants').add(data.toMap());
    } catch (e, st) {
      developer.log('Erro ao criar planta: $e', name: 'PlantService', stackTrace: st);
      rethrow;
    }
  }

  Future<void> updatePlant(Plant plant) async {
    await _db.collection('plants').doc(plant.id).update(plant.toMap());
  }

  Future<void> deletePlant(String id) async {
    await _db.collection('plants').doc(id).delete();
  }
}

