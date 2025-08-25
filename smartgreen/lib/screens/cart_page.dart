import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'address_selection_page.dart';
import 'payment_page.dart';
import '../widgets/custom_button.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<bool> confirmRemoveProduct(BuildContext ctx, CartItem item) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: ctx,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.remove_shopping_cart,
                  color: Colors.red,
                  size: 36,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Remover item do carrinho?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  item.product.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(sheetCtx, true),
                        child: const Text('Remover'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        backgroundColor: Colors.green, // AppBar verde
      ),
      body:
          cart.items.isEmpty
              ? const Center(child: Text('Seu carrinho está vazio'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        final price = item.product.price;
                        final quantity = item.quantity;
                        final subtotal = price * quantity;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    color: Colors.grey.shade300,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'R\$ ${price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Subtotal no formato da “imagem 2”
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: isCompact ? 96 : 120,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Diminuir (com confirmação ao sair de 1 -> 0)
                                  Material(
                                    color: Colors.grey.shade200,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () async {
                                        if (quantity <= 1) {
                                          final ok = await confirmRemoveProduct(
                                            context,
                                            item,
                                          );
                                          if (ok) {
                                            cart.removeFromCart(item.product);
                                          }
                                        } else {
                                          cart.updateQuantity(
                                            item.product,
                                            quantity - 1,
                                          );
                                        }
                                      },
                                      child: const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Icon(Icons.remove, size: 20),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  // Aumentar
                                  Material(
                                    color: Colors.grey.shade200,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        cart.updateQuantity(
                                          item.product,
                                          quantity + 1,
                                        );
                                      },
                                      child: const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Icon(Icons.add, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          label: 'Continuar',
                          icon: Icons.shopping_cart_checkout,
                          backgroundColor: Colors.green,
                          onPressed: () async {
                            final selectedAddress = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const AddressSelectionPage(
                                      cameFromCart: true,
                                    ),
                              ),
                            );

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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
