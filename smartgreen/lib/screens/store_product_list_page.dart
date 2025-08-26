import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../services/store_product_service.dart';
import 'store_product_form_page.dart';
import 'store_product_detail_page.dart';

class ProductListPage
    extends
        StatefulWidget {
  const ProductListPage({
    super.key,
  });

  @override
  State<
    ProductListPage
  >
  createState() =>
      _ProductListPageState();
}

class _ProductListPageState
    extends
        State<
          ProductListPage
        > {
  final _service =
      StoreProductService();
  final _searchCtrl =
      TextEditingController();
  String _search =
      '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => setState(
        () =>
            _search =
                _searchCtrl.text,
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _confirmDelete(
    StoreProduct p,
  ) async {
    final ok =
        await showDialog<
          bool
        >(
          context:
              context,
          builder:
              (
                _,
              ) => AlertDialog(
                title: const Text(
                  'Remover produto',
                ),
                content: Text(
                  'Deseja remover "${p.CientificName}"?',
                ),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.pop(
                          context,
                          false,
                        ),
                    child: const Text(
                      'Cancelar',
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.pop(
                          context,
                          true,
                        ),
                    child: const Text(
                      'Remover',
                    ),
                  ),
                ],
              ),
        ) ??
        false;
    if (ok)
      await _service.delete(
        p.id,
      );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Produtos',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (
                      _,
                    ) =>
                        const StoreProductFormPage(),
              ),
            ),
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Novo produto',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8,
            ),
            child: TextField(
              controller:
                  _searchCtrl,
              decoration: InputDecoration(
                hintText:
                    'Pesquisar...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<
              List<
                StoreProduct
              >
            >(
              stream: _service.stream(
                search:
                    _search,
              ),
              builder: (
                context,
                snap,
              ) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }
                final items =
                    snap.data ??
                    [];
                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(
                        24,
                      ),
                      child: Text(
                        'Nenhum produto encontrado.',
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    96,
                  ),
                  itemCount:
                      items.length,
                  separatorBuilder:
                      (
                        _,
                        __,
                      ) => const SizedBox(
                        height:
                            8,
                      ),
                  itemBuilder: (
                    _,
                    i,
                  ) {
                    final p = items[i];
                    return Dismissible(
                      key: ValueKey(
                        p.id,
                      ),
                      background: Container(
                        alignment:
                            Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          left:
                              16,
                        ),
                        color:
                            Colors.red.shade400,
                        child: const Icon(
                          Icons.delete,
                          color:
                              Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment:
                            Alignment.centerRight,
                        padding: const EdgeInsets.only(
                          right:
                              16,
                        ),
                        color:
                            Colors.red.shade400,
                        child: const Icon(
                          Icons.delete,
                          color:
                              Colors.white,
                        ),
                      ),
                      confirmDismiss: (
                        _,
                      ) async {
                        await _confirmDelete(
                          p,
                        );
                        return false; // evitamos sumir com o tile antes; recarrega pelo stream
                      },
                      child: ListTile(
                        leading:
                            (p.imageURL.isNotEmpty)
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                  child: Image.network(
                                    p.imageURL,
                                    width:
                                        56,
                                    height:
                                        56,
                                    fit:
                                        BoxFit.cover,
                                    errorBuilder:
                                        (
                                          _,
                                          __,
                                          ___,
                                        ) => const Icon(
                                          Icons.inventory_2,
                                        ),
                                  ),
                                )
                                : const CircleAvatar(
                                  child: Icon(
                                    Icons.inventory_2,
                                  ),
                                ),
                        title: Text(
                          p.CientificName,
                        ),
                        subtitle: Text(
                          [
                            if ((p.category ??
                                    '')
                                .isNotEmpty)
                              p.category!,
                            'R\$ ${p.PrecoUnt.toStringAsFixed(2)}',
                            if (p.stock !=
                                null)
                              'Estoque: ${p.stock}',
                          ].join(
                            ' • ',
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      _,
                                    ) => StoreProductDetailPage(
                                      storeProductId:
                                          p.id,
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
        ],
      ),
    );
  }
}
