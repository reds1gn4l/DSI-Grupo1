import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../widgets/custom_button.dart';

class ProductDetailPage
    extends
        StatelessWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.CientificName,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag:
                    product.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                  child: Image.network(
                    product.imageURL,
                    height:
                        200,
                    fit:
                        BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height:
                  16,
            ),
            Text(
              product.CientificName,
              style: const TextStyle(
                fontSize:
                    24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height:
                  8,
            ),
            Text(
              'R\$ ${product.PrecoUnt.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize:
                    20,
                color:
                    Colors.green[700],
              ),
            ),
            if (product.category !=
                    null &&
                product.category!.isNotEmpty)
              Text(
                'Categoria: ${product.category}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            if (product.stock !=
                null)
              Text(
                'Estoque: ${product.stock}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            if (product.ValDias !=
                null)
              Text(
                'Validade (dias): ${product.ValDias}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            if (product.DataPlantio !=
                null)
              Text(
                'Data de Plantio: '
                '${product.DataPlantio!.day.toString().padLeft(2, '0')}-'
                '${product.DataPlantio!.month.toString().padLeft(2, '0')}-'
                '${product.DataPlantio!.year}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            if (product.FxTemp.isNotEmpty)
              Text(
                'Faixa de Temperatura: ${product.FxTemp}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            if (product.FxUmidade.isNotEmpty)
              Text(
                'Faixa de Umidade: ${product.FxUmidade}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            if (product.TempoSol.isNotEmpty)
              Text(
                'Tempo de Sol: ${product.TempoSol}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            const SizedBox(
              height:
                  16,
            ),
            if (product.DescricaoPlanta.isNotEmpty)
              Text(
                'Descrição da Planta: ${product.DescricaoPlanta}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            if (product.DescricaoProd.isNotEmpty)
              Text(
                'Descrição do Produto: ${product.DescricaoProd}',
                style: const TextStyle(
                  fontSize:
                      16,
                ),
              ),
            const Spacer(),
            SizedBox(
              width:
                  double.infinity,
              child: CustomButton(
                label:
                    'Adicionar ao Carrinho',
                icon:
                    Icons.add_shopping_cart,
                onPressed: () {
                  final cart = Provider.of<
                    CartService
                  >(
                    context,
                    listen:
                        false,
                  );
                  cart.addToCart(
                    product,
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Produto adicionado ao carrinho!',
                      ),
                      duration: const Duration(
                        seconds:
                            1,
                      ),
                      action: SnackBarAction(
                        label:
                            'Fechar',
                        textColor:
                            Colors.yellow,
                        onPressed: () {
                          ScaffoldMessenger.of(
                            context,
                          ).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
