import 'package:flutter/material.dart';
import '../models/plant.dart'; 
import '../globals.dart';
import '../services/plant_service.dart';
import '../widgets/plant_card_widget.dart';
import '../widgets/leaf_glyph.dart';
import 'plant_form_page.dart';
import 'plant_detail_page.dart';

class PlantListPage extends StatefulWidget {
  const PlantListPage({super.key});

  @override
  PlantListPageState createState() => PlantListPageState();
}

class PlantListPageState extends State<PlantListPage> {
  final _service = PlantService();
  String _search = '';

  String get searchHint => 'Buscar Planta';
  void applySearch(String q) =>
      setState(() => _search = q.trim().toLowerCase());

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final cs = Theme.of(context).colorScheme;
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Remover planta'),
                content: Text('Tem certeza que deseja remover "$name"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Remover', style: TextStyle(color: cs.error)),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final uid = currentUser?.id;
    return Scaffold( 
      body: uid == null
          ? const Center(child: Text('Faça login para ver suas plantas'))
          : StreamBuilder<List<Plant>>( 
        stream: _service.getPlantsByUser(uid), 
        builder: (context, snapshot) { 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final plants = snapshot.data ?? const <Plant>[]; 
          final filtered =
              plants
                  .where((p) => p.name.toLowerCase().contains(_search))
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name));

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LeafGlyph.empty(), // corrigido: sem const
                  const SizedBox(height: 8),
                  const Text('Nenhuma planta cadastrada'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: filtered.length,
            itemBuilder:
                (_, index) => PlantCardWidget(
                  plant: filtered[index],
                  onDelete: () async {
                    final confirm = await _confirmDelete(
                      context,
                      filtered[index].name,
                    );
                    if (confirm) {
                      await _service.deletePlant(filtered[index].id);
                      setState(() {});
                    }
                  },
                  onEdit: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                PlantFormPage(existingPlant: filtered[index]),
                      ),
                    );
                    setState(() {});
                  },
                  onOpen: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => PlantDetailPage(plantId: filtered[index].id),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                ),
          );
        }, 
      ), 
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PlantFormPage()));
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar nova planta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
