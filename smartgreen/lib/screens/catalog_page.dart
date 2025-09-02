// lib/screens/catalog_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../models/product.dart';
import '../shared/searchable_tab.dart';
import 'cart_page.dart'; // fallback se não passarem o callback
import 'product_detail_page.dart';

class CatalogPage
    extends
        StatefulWidget {
  const CatalogPage({
    super.key,
    this.goToCart,
  });
  final VoidCallback? goToCart; // callback para trocar a aba

  @override
  CatalogPageState createState() =>
      CatalogPageState();
}

class CatalogPageState
    extends
        State<
          CatalogPage
        >
    with
        SearchableTab {
  final ProductService _productService =
      ProductService();
  String _searchQuery =
      '';

  @override
  String get searchHint =>
      'Buscar Produto';

  @override
  void applySearch(
    String query,
  ) {
    setState(
      () =>
          _searchQuery =
              query.trim().toLowerCase(),
    );
  }

  // SnackBar que flutua acima da barra do carrinho
  SnackBar _cartSnack(
    String message, {
    VoidCallback? onUndo,
  }) {
    const double cartBarHeight =
        60.0;
    final double bottomGap =
        cartBarHeight +
        16 +
        MediaQuery.of(
          context,
        ).padding.bottom;

    return SnackBar(
      content: Text(
        message,
      ),
      behavior:
          SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        bottomGap,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      duration: const Duration(
        seconds:
            3,
      ),
      action:
          onUndo ==
                  null
              ? null
              : SnackBarAction(
                label:
                    'Desfazer',
                onPressed:
                    onUndo,
              ),
    );
  }

  Future<
    void
  >
  _quickAdd(
    Product p,
  ) async {
    final cart =
        context
            .read<
              CartService
            >();
    cart.addToCart(
      p,
    ); // adiciona 1

    if (!mounted) return;
    ScaffoldMessenger.of(
        context,
      )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _cartSnack(
          '"${p.nome}" Adicionado ao carrinho',
          onUndo: () {
            try {
              final item = cart.items.firstWhere(
                (
                  e,
                ) =>
                    e.product.id ==
                    p.id,
              );
              final newQty =
                  item.quantity -
                  1;
              if (newQty <=
                  0) {
                cart.removeFromCart(
                  p,
                );
              } else {
                cart.updateQuantity(
                  p,
                  newQty,
                );
              }
            } catch (
              _
            ) {}
          },
        ),
      );
  }

  Future<
    void
  >
  _chooseQtyAndAdd(
    Product p,
  ) async {
    final theme = Theme.of(
      context,
    );
    final cs =
        theme.colorScheme;
    int qty =
        1;

    await showModalBottomSheet(
      context:
          context,
      isScrollControlled:
          false,
      showDragHandle:
          true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            16,
          ),
        ),
      ),
      builder: (
        _,
      ) {
        return StatefulBuilder(
          builder: (
            context,
            setModal,
          ) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                20,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    p.nome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
                    maxLines:
                        1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip:
                            'Diminuir',
                        onPressed:
                            qty >
                                    1
                                ? () => setModal(
                                  () =>
                                      qty--,
                                )
                                : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal:
                              16,
                        ),
                        child: Text(
                          '$qty',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip:
                            'Aumentar',
                        onPressed:
                            () => setModal(
                              () =>
                                  qty++,
                            ),
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  SizedBox(
                    width:
                        double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            cs.primary,
                        foregroundColor:
                            cs.onPrimary,
                        minimumSize: const Size.fromHeight(
                          48,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_shopping_cart,
                      ),
                      label: Text(
                        'Adicionar $qty ao carrinho',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        final cart =
                            context
                                .read<
                                  CartService
                                >();
                        for (
                          var i = 0;
                          i <
                              qty;
                          i++
                        ) {
                          cart.addToCart(
                            p,
                          );
                        }
                        Navigator.pop(
                          context,
                        );
                        ScaffoldMessenger.of(
                            context,
                          )
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            _cartSnack(
                              '$qty × "${p.nome}" adicionados',
                            ),
                          );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    final cs =
        theme.colorScheme;

    final screenWidth =
        MediaQuery.of(
          context,
        ).size.width;
    const crossAxisCount =
        2;
    final itemWidth =
        (screenWidth -
            30) /
        crossAxisCount;
    const itemHeight =
        280.0;
    final aspectRatio =
        itemWidth /
        itemHeight;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<
            List<
              Product
            >
          >(
            stream:
                _productService.getProducts(),
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao carregar produtos',
                  ),
                );
              }

              List<
                Product
              >
              products =
                  snapshot.data ??
                  [];
              if (_searchQuery.isNotEmpty) {
                products =
                    products
                        .where(
                          (
                            p,
                          ) => p.nome.toLowerCase().contains(
                            _searchQuery,
                          ),
                        )
                        .toList();
              }

              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum produto encontrado.',
                  ),
                );
              }

              return Stack(
                children: [
                  // grade de produtos
                  GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      10,
                      10,
                      90,
                    ),
                    itemCount:
                        products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          crossAxisCount,
                      childAspectRatio:
                          aspectRatio,
                      crossAxisSpacing:
                          10,
                      mainAxisSpacing:
                          10,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final product =
                          products[index];
                      return Card(
                        elevation:
                            theme.cardTheme.elevation ??
                            3,
                        color:
                            theme.cardTheme.color, // pega do theme (surfaceContainer nível)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      _,
                                    ) => ProductDetailPage(
                                      product:
                                          product,
                                    ),
                              ),
                            );
                          },
                          onLongPress:
                              () => _chooseQtyAndAdd(
                                product,
                              ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Hero(
                                  tag:
                                      product.id,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(
                                        12,
                                      ),
                                      topRight: Radius.circular(
                                        12,
                                      ),
                                    ),
                                    child: Image.network(
                                      product.imageURL,
                                      fit:
                                          BoxFit.cover,
                                      errorBuilder:
                                          (
                                            _,
                                            __,
                                            ___,
                                          ) => const Center(
                                            child: Icon(
                                              Icons.image,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  0,
                                ),
                                child: Text(
                                  product.nome,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                  maxLines:
                                      1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  2,
                                  10,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'R\$ ${product.precoUnt.toStringAsFixed(2)}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            cs.primary,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      height:
                                          36,
                                      width:
                                          44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              cs.primary,
                                          foregroundColor:
                                              cs.onPrimary,
                                          padding:
                                              EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            () => _quickAdd(
                                              product,
                                            ),
                                        onLongPress:
                                            () => _chooseQtyAndAdd(
                                              product,
                                            ),
                                        child: const Icon(
                                          Icons.add_shopping_cart,
                                          size:
                                              20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // barra flutuante do carrinho (resumo)
                  Consumer<
                    CartService
                  >(
                    builder: (
                      context,
                      cart,
                      _,
                    ) {
                      if (cart.items.isEmpty) return const SizedBox.shrink();
                      final total = cart.totalPrice.toStringAsFixed(
                        2,
                      );
                      final count = cart.items.fold<
                        int
                      >(
                        0,
                        (
                          sum,
                          e,
                        ) =>
                            sum +
                            e.quantity,
                      );

                      return Positioned(
                        left:
                            10,
                        right:
                            10,
                        bottom:
                            10,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          onTap: () {
                            if (widget.goToCart !=
                                null) {
                              widget.goToCart!();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (
                                        _,
                                      ) =>
                                          const CartPage(),
                                ),
                              );
                            }
                          },
                          child: Material(
                            elevation:
                                4,
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal:
                                    12,
                                vertical:
                                    12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.cardColor, // contrasta com o scaffold
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                                border: Border.all(
                                  color:
                                      theme.dividerColor,
                                ), // usa theme
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.shopping_cart_outlined,
                                  ),
                                  const SizedBox(
                                    width:
                                        8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$count item${count == 1 ? '' : 's'} • R\$ $total',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
