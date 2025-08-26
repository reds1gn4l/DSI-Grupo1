import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../globals.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'store_product_list_page.dart';

class CatalogPage
    extends
        StatefulWidget {
  const CatalogPage({
    super.key,
  });

  @override
  State<
    CatalogPage
  >
  createState() =>
      _CatalogPageState();
}

class _CatalogPageState
    extends
        State<
          CatalogPage
        > {
  final ProductService _productService =
      ProductService();
  String _searchQuery =
      '';

  @override
  Widget build(
    BuildContext context,
  ) {
    final screenWidth =
        MediaQuery.of(
          context,
        ).size.width;
    final crossAxisCount =
        2;
    final itemWidth =
        (screenWidth -
            30) /
        crossAxisCount;
    final itemHeight =
        250;
    final aspectRatio =
        itemWidth /
        itemHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo de Sementes',
        ),
        centerTitle:
            true,
        toolbarHeight:
            60,
        backgroundColor:
            Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: TextField(
              decoration: const InputDecoration(
                labelText:
                    'Buscar produto...',
                prefixIcon: Icon(
                  Icons.search,
                ),
                border:
                    OutlineInputBorder(),
              ),
              textInputAction:
                  TextInputAction.search,
              onChanged: (
                value,
              ) {
                setState(
                  () {
                    _searchQuery =
                        value.trim().toLowerCase();
                  },
                );
              },
              onSubmitted: (
                value,
              ) {
                setState(
                  () {
                    _searchQuery =
                        value.trim().toLowerCase();
                  },
                );
              },
            ),
          ),
          if (getUserData()?.isAdmin ==
              true)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal:
                    8.0,
              ),
              child: SizedBox(
                width:
                    double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              _,
                            ) =>
                                ProductListPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Ver lista de produtos',
                  ),
                ),
              ),
            ),
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
                            ) => p.CientificName.toLowerCase().contains(
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

                return GridView.builder(
                  padding: const EdgeInsets.all(
                    10,
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
                          4,
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
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: Text(
                                product.CientificName,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal:
                                    8.0,
                              ),
                              child: Text(
                                'R\$ ${product.PrecoUnt.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color:
                                      Colors.green[800],
                                ),
                              ),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
        },
        backgroundColor:
            Colors.green,
        child: const Icon(
          Icons.shopping_cart,
        ),
      ),
    );
  }
}
