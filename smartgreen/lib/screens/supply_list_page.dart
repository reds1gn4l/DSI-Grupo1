import 'package:flutter/material.dart';
import '../models/supply.dart';
import '../services/supply_service.dart';
import 'supply_form_page.dart';
import '../shared/searchable_tab.dart';
import '../widgets/custom_button.dart';

class SupplyListPage extends StatefulWidget {
  const SupplyListPage({super.key});

  @override
  SupplyListPageState createState() => SupplyListPageState();
}

class SupplyListPageState extends State<SupplyListPage> with SearchableTab {
  final SupplyService _service = SupplyService();
  String _searchQuery = '';

  @override
  String get searchHint => 'Pesquisar insumo...';

  @override
  void applySearch(String query) {
    setState(() => _searchQuery = query.toLowerCase().trim());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Supply>>(
            stream: _service.getSupplies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar insumos.'));
              }

              final all = snapshot.data ?? [];
              final filtered = all
                  .where((s) => s.name.toLowerCase().contains(_searchQuery))
                  .toList();

             
              if (filtered.isEmpty) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            size: 48,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          const Text('Nenhum insumo encontrado.'),
                          const SizedBox(height: 16),
                          CustomButton(
                            label: 'Cadastrar novo insumo',
                            icon: Icons.add,
                            backgroundColor: cs.primary,
                            textColor: cs.onPrimary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SupplyFormPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final supply = filtered[index];

                  return Dismissible(
                    key: ValueKey(supply.id),
                    direction: DismissDirection.endToStart, 
                    confirmDismiss: (_) async {
                      final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir insumo'),
                              content: const Text(
                                'Deseja realmente excluir este insumo?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (ok) await _service.deleteSupply(supply.id);
                      return false; 
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: cs.error,
                      child: Icon(Icons.delete, color: cs.onError),
                    ),
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupplyFormPage(supply: supply),
                            ),
                          );
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: _buildLeadingImage(supply),
                          title: Text(
                            supply.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Quantidade: ${supply.quantity}\nValidade: ${supply.validity}',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SafeArea(
            top: false,
            child: CustomButton(
              label: 'Cadastrar novo insumo',
              icon: Icons.add,
              backgroundColor: cs.primary,
              textColor: cs.onPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupplyFormPage()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadingImage(Supply supply) {
    final radius = BorderRadius.circular(8);
    if (supply.imageUrl != null && supply.imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          supply.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _FallbackLeafIcon(),
        ),
      );
    }
    return const _FallbackLeafIcon();
  }
}

class _FallbackLeafIcon extends StatelessWidget {
  const _FallbackLeafIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.local_florist,
      size: 40,
      color: Colors.black38,
    );
  }
}