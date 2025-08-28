// lib/screens/product_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/custom_button.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Evita quebra de linha entre "R$" e o valor
    String money(num v) =>
        'R\$ ${v.toStringAsFixed(2)}'.replaceFirst(' ', '\u00A0');

    return Scaffold(
      appBar: AppBar(
        title: Text(product.cientificName),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: product.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.imageURL,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 220,
                          alignment: Alignment.center,
                          color: cs.surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nome
            Text(
              product.cientificName,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),

            // Preço
            Text(
              money(product.precoUnt),
              style: tt.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 24),

            // Meta-infos
            if (product.category != null && product.category!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Categoria: ${product.category}',
                  style: tt.bodyMedium,
                ),
              ),
            if (product.stock != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('Estoque: ${product.stock}', style: tt.bodyMedium),
              ),
            if (product.valDias != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Validade (dias): ${product.valDias}',
                  style: tt.bodyMedium,
                ),
              ),
            if (product.dataPlantio != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Data de Plantio: '
                  '${product.dataPlantio!.day.toString().padLeft(2, '0')}-'
                  '${product.dataPlantio!.month.toString().padLeft(2, '0')}-'
                  '${product.dataPlantio!.year}',
                  style: tt.bodyMedium,
                ),
              ),
            if (product.fxTemp.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Faixa de Temperatura: ${product.fxTemp}',
                  style: tt.bodyMedium,
                ),
              ),
            if (product.fxUmidade.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Faixa de Umidade: ${product.fxUmidade}',
                  style: tt.bodyMedium,
                ),
              ),
            if (product.tempoSol.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Tempo de Sol: ${product.tempoSol}',
                  style: tt.bodyMedium,
                ),
              ),

            const SizedBox(height: 12),

            if (product.descricaoPlanta.isNotEmpty) ...[
              Text(
                'Descrição da Planta:',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(product.descricaoPlanta, style: tt.bodyMedium),
              const SizedBox(height: 12),
            ],
            if (product.descricaoProd.isNotEmpty) ...[
              Text(
                'Descrição do Produto:',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(product.descricaoProd, style: tt.bodyMedium),
            ],

            const Spacer(),

            // Botão "Adicionar ao Carrinho"
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Adicionar ao Carrinho',
                icon: Icons.add_shopping_cart,
                backgroundColor: cs.primary,
                textColor: cs.onPrimary,
                onPressed: () {
                  final cart = Provider.of<CartService>(context, listen: false);
                  cart.addToCart(product);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: const Text('Produto adicionado ao carrinho!'),
                        action: SnackBarAction(
                          label: 'Fechar',
                          textColor: cs.secondary,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                        duration: const Duration(seconds: 2),
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
