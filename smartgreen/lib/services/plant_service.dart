import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<Plant>> getAllPlants() async {
    final snap = await _db.collection('plants').get();

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
    await _db.collection('plants').add(plant.toMap());
  }

  Future<void> updatePlant(Plant plant) async {
    await _db.collection('plants').doc(plant.id).update(plant.toMap());
  }

  Future<void> deletePlant(String id) async {
    await _db.collection('plants').doc(id).delete();
  }
}
