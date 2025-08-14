import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../widgets/plant_card_widget.dart';
import '../widgets/leaf_glyph.dart';
import 'plant_form_page.dart';

class PlantListPage extends StatefulWidget {
  const PlantListPage({super.key});

  @override
  State<PlantListPage> createState() => _PlantListPageState();
}

class _PlantListPageState extends State<PlantListPage> {
  final PlantService _service = PlantService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final newQuery = _searchController.text.trim();
      if (newQuery != _query) {
        setState(() => _query = newQuery);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Conteúdo (busca + lista / placeholder)
        Column(
          children: [
            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Pesquisar planta...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  suffixIcon:
                      _query.isEmpty
                          ? null
                          : IconButton(
                            tooltip: 'Limpar',
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          ),
                ),
              ),
            ),

            // Lista de cards OU folha gigante (se vazio)
            Expanded(
              child: StreamBuilder<List<Plant>>(
                stream: _service.getPlants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar plantas'),
                    );
                  }

                  final plants = snapshot.data ?? [];

                  if (plants.isEmpty) {
                    // Placeholder com a folha cinza
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        final leafSize = availableHeight * 0.5; // ~50%

                        return Center(
                          child: Padding(
                            // deixa espaço pro botão que fica por cima
                            padding: const EdgeInsets.only(bottom: 96),
                            child: LeafGlyph(
                              size: leafSize,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Reordena: correspondentes primeiro, resto depois
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
                    padding: const EdgeInsets.only(bottom: 110),
                    itemCount: ordered.length,
                    itemBuilder: (context, index) {
                      final plant = ordered[index];
                      return PlantCardWidget(plant: plant);
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // Botão flutuante centralizado no rodapé
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
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
              backgroundColor: const Color(0xFFA5D6A7), // tom verdinho suave
              foregroundColor: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
