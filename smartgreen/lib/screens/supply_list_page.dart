// lib/screens/supply_list_page.dart
import 'package:flutter/material.dart';
import '../models/supply.dart';
import '../services/supply_service.dart';
import 'supply_form_page.dart';
import '../shared/searchable_tab.dart';

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
    setState(() => _searchQuery = query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Supply>>(
            stream: _service.getSupplies(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered =
                  snapshot.data!
                      .where((s) => s.name.toLowerCase().contains(_searchQuery))
                      .toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('Nenhum insumo encontrado.'));
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final supply = filtered[index];
                  return Dismissible(
                    key: Key(supply.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Excluir insumo'),
                              content: const Text(
                                'Deseja realmente excluir este insumo?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) {
                      _service.deleteSupply(supply.id);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.local_florist),
                      title: Text(supply.name),
                      subtitle: Text(
                        'Quantidade: ${supply.quantity}\nValidade: ${supply.validity}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupplyFormPage(supply: supply),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupplyFormPage()),
              );
            },
            child: const Text('Cadastrar novo item'),
          ),
        ),
      ],
    );
  }
}
