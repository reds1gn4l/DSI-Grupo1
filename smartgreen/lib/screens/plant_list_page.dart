// lib/screens/plant_list_page.dart
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../widgets/plant_card_widget.dart';
import '../widgets/leaf_glyph.dart';
import 'plant_form_page.dart';
import '../shared/searchable_tab.dart';

class PlantListPage extends StatefulWidget {
  const PlantListPage({super.key});

  @override
  PlantListPageState createState() => PlantListPageState();
}

class PlantListPageState extends State<PlantListPage> with SearchableTab {
  final PlantService _service = PlantService();
  String _query = '';

  @override
  String get searchHint => 'Pesquisar planta...';

  @override
  void applySearch(String query) => setState(() => _query = query.trim());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        StreamBuilder<List<Plant>>(
          stream: _service.getPlants(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar plantas'));
            }

            final plants = snapshot.data ?? [];
            if (plants.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final leafSize = constraints.maxHeight * 0.5;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 96),
                      child: LeafGlyph(
                        size: leafSize,
                        // usa cor do tema com leve transparência
                        color: cs.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                  );
                },
              );
            }

            final q = _query.toLowerCase();
            final matches = <Plant>[];
            final nonMatches = <Plant>[];
            for (final p in plants) {
              final name = p.name.toLowerCase();
              if (q.isEmpty || name.contains(q)) {
                matches.add(p);
              } else {
                nonMatches.add(p);
              }
            }
            final ordered = [...matches, ...nonMatches];

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 110, top: 8),
              itemCount: ordered.length,
              itemBuilder: (context, index) {
                return PlantCardWidget(plant: ordered[index]);
              },
            );
          },
        ),

        // FAB estendido usando o tema (primary/onPrimary)
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Center(
              child: FloatingActionButton.extended(
                heroTag: 'fab_add_plant',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlantFormPage()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Cadastrar nova planta'),
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
