import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../widgets/custom_button.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.cientificName)),
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
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.cientificName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${product.precoUnt.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, color: Colors.green[700]),
            ),
            if (product.category != null && product.category!.isNotEmpty)
              Text(
                'Categoria: ${product.category}',
                style: const TextStyle(fontSize: 16),
              ),
            if (product.stock != null)
              Text(
                'Estoque: ${product.stock}',
                style: const TextStyle(fontSize: 16),
              ),
            if (product.valDias != null)
              Text(
                'Validade (dias): ${product.valDias}',
                style: const TextStyle(fontSize: 16),
              ),
            if (product.dataPlantio != null)
              Text(
                'Data de Plantio: '
                '${product.dataPlantio!.day.toString().padLeft(2, '0')}-'
                '${product.dataPlantio!.month.toString().padLeft(2, '0')}-'
                '${product.dataPlantio!.year}',
                style: const TextStyle(fontSize: 16),
              ),
            if (product.fxTemp.isNotEmpty)
              Text(
                'Faixa de Temperatura: ${product.fxTemp}',
                style: const TextStyle(fontSize: 16),
              ),
            if (product.fxUmidade.isNotEmpty)
              Text(
                'Faixa de Umidade: ${product.fxUmidade}',
                style: const TextStyle(fontSize: 16),
              ),
            if (product.tempoSol.isNotEmpty)
              Text(
                'Tempo de Sol: ${product.tempoSol}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (product.descricaoPlanta.isNotEmpty)
              Text(
                'Descrição da Planta: ${product.descricaoPlanta}',
                style: const TextStyle(fontSize: 16),
              ),
            if (product.descricaoProd.isNotEmpty)
              Text(
                'Descrição do Produto: ${product.descricaoProd}',
                style: const TextStyle(fontSize: 16),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Adicionar ao Carrinho',
                icon: Icons.add_shopping_cart,
                onPressed: () {
                  final cart = Provider.of<CartService>(context, listen: false);
                  cart.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Produto adicionado ao carrinho!'),
                      duration: const Duration(seconds: 1),
                      action: SnackBarAction(
                        label: 'Fechar',
                        textColor: Colors.yellow,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
