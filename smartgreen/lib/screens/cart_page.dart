import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'address_selection_page.dart';
import 'payment_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body:
          cart.items.isEmpty
              ? const Center(child: Text('Seu carrinho está vazio'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        CartItem item = cart.items[index];
                        return ListTile(
                          leading: Image.network(
                            item.product.imageUrl,
                            width: 50,
                          ),
                          title: Text(item.product.name),
                          subtitle: Text(
                            'R\$ ${item.product.price.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  int newQty = item.quantity - 1;
                                  if (newQty <= 0) {
                                    cart.removeFromCart(item.product);
                                  } else {
                                    cart.updateQuantity(item.product, newQty);
                                  }
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  cart.updateQuantity(
                                    item.product,
                                    item.quantity + 1,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final selectedAddress = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressSelectionPage(),
                              ),
                            );

                            // Verificação correta e segura
                            if (context.mounted && selectedAddress != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PaymentPage(
                                        selectedAddress: selectedAddress,
                                      ),
                                ),
                              );
                            }
                          },
                          child: const Text('Finalizar Compra'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
