// lib/screens/store_product_list_page.dart
import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../services/store_product_service.dart';
import 'store_product_form_page.dart';
import 'store_product_detail_page.dart';
import '../widgets/custom_button.dart';
import '../globals.dart';
import 'login_screen.dart';

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

  Color get _green => const Color(
    0xFF2E7D32,
  );

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () {
        setState(
          () =>
              _search =
                  _searchCtrl.text.trim(),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _logout() {
    saveUserData(
      id:
          null,
      name:
          '',
      email:
          '',
      address:
          null,
      isAdmin:
          false,
    );
    Navigator.of(
      context,
    ).pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (
              _,
            ) =>
                const LoginScreen(),
      ),
      (
        route,
      ) =>
          false,
    );
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
                  'Deseja remover "${p.nome}"?',
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
    if (ok) {
      await _service.delete(
        p.id,
      );
    }
  }

  AppBar _topBar(
    BuildContext context,
  ) {
    final canPop =
        Navigator.of(
          context,
        ).canPop();
    return AppBar(
      automaticallyImplyLeading:
          false,
      backgroundColor:
          _green,
      elevation:
          0,
      titleSpacing:
          0,
      title: Padding(
        padding: const EdgeInsets.only(
          left:
              8,
          right:
              8,
          top:
              6,
          bottom:
              6,
        ),
        child: Row(
          children: [
            if (canPop)
              IconButton(
                tooltip:
                    'Voltar',
                icon: const Icon(
                  Icons.arrow_back,
                  color:
                      Colors.white,
                ),
                onPressed:
                    () =>
                        Navigator.of(
                          context,
                        ).maybePop(),
              ),
            Expanded(
              child: Container(
                height:
                    40,
                padding: const EdgeInsets.symmetric(
                  horizontal:
                      12,
                ),
                decoration: BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius: BorderRadius.circular(
                    24,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size:
                          22,
                      color:
                          Colors.black54,
                    ),
                    const SizedBox(
                      width:
                          8,
                    ),
                    Expanded(
                      child: TextField(
                        controller:
                            _searchCtrl,
                        style: const TextStyle(
                          height:
                              1.2,
                        ),
                        decoration: const InputDecoration(
                          isDense:
                              true,
                          hintText:
                              'Buscar produto...',
                          // remove QUALQUER borda/outline (inclusive foco/erro)
                          border:
                              InputBorder.none,
                          enabledBorder:
                              InputBorder.none,
                          focusedBorder:
                              InputBorder.none,
                          disabledBorder:
                              InputBorder.none,
                          errorBorder:
                              InputBorder.none,
                          focusedErrorBorder:
                              InputBorder.none,
                          contentPadding:
                              EdgeInsets.zero,
                          // sem fundo próprio; o branco vem do Container
                          filled:
                              false,
                        ),
                        textInputAction:
                            TextInputAction.search,
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      IconButton(
                        tooltip:
                            'Limpar',
                        icon: const Icon(
                          Icons.clear,
                          color:
                              Colors.black54,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(
                            () {},
                          ); // atualiza ícone
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width:
                  8,
            ),
            PopupMenuButton<
              String
            >(
              icon: const Icon(
                Icons.settings,
                color:
                    Colors.white,
              ),
              tooltip:
                  'Menu',
              onSelected: (
                v,
              ) {
                if (v ==
                    'logout') {
                  _logout();
                }
              },
              itemBuilder:
                  (
                    _,
                  ) => const [
                    PopupMenuItem(
                      value:
                          'logout',
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                        ),
                        title: Text(
                          'Sair',
                        ),
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade50,
      appBar: _topBar(
        context,
      ),
      body: StreamBuilder<
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

          // ====== SEM PRODUTOS: botão centralizado ======
          if (items.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth:
                      420,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size:
                            48,
                        color:
                            Colors.black26,
                      ),
                      const SizedBox(
                        height:
                            12,
                      ),
                      const Text(
                        'Nenhum produto encontrado.',
                        textAlign:
                            TextAlign.center,
                      ),
                      const SizedBox(
                        height:
                            16,
                      ),
                      CustomButton(
                        label:
                            'Adicionar Novo Produto',
                        icon:
                            Icons.add,
                        backgroundColor: const Color(
                          0xFF1E88E5,
                        ),
                        textColor:
                            Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    _,
                                  ) =>
                                      const StoreProductFormPage(),
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

          // ====== COM PRODUTOS: lista + botão como último item ======
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              16,
            ),
            itemCount:
                items.length +
                1, // último item é o botão
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
              index,
            ) {
              // Botão no final da lista
              if (index ==
                  items.length) {
                return CustomButton(
                  label:
                      'Adicionar Novo Produto',
                  icon:
                      Icons.add,
                  backgroundColor: const Color(
                    0xFF1E88E5,
                  ),
                  textColor:
                      Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              _,
                            ) =>
                                const StoreProductFormPage(),
                      ),
                    );
                  },
                );
              }

              final p = items[index];
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
                  return false; // stream recarrega depois
                },
                child: Card(
                  elevation:
                      3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal:
                          12,
                      vertical:
                          8,
                    ),
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
                      p.nome,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                      maxLines:
                          1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(
                        top:
                            4,
                      ),
                      child: Text(
                        [
                          if ((p.category ??
                                  '')
                              .isNotEmpty)
                            p.category!,
                          'R\$ ${p.precoUnt.toStringAsFixed(2)}',
                          if (p.stock !=
                              null)
                            'Estoque: ${p.stock}',
                        ].join(
                          ' • ',
                        ),
                      ),
                    ),
                    // AGORA: toque = detalhes | segurar = editar
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (
                                  _,
                                ) => StoreProductDetailPage(
                                  product:
                                      p,
                                ),
                          ),
                        ),
                    onLongPress:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (
                                  _,
                                ) => StoreProductFormPage(
                                  storeProduct:
                                      p,
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
    );
  }
}
