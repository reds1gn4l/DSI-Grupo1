import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';

class PlantService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'plants',
  );

  Stream<List<Plant>> getPlants() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Plant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addPlant(Plant plant) async {
    await _collection.add(plant.toMap());
  }

  Future<void> updatePlant(Plant plant) async {
    await _collection.doc(plant.id).update(plant.toMap());
  }

  Future<void> deletePlant(String id) async {
    await _collection.doc(id).delete();
  }
}
