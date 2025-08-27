import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'address_selection_page.dart';
import 'payment_page.dart';
import '../widgets/custom_button.dart';

/// Tela completa (quando abrimos o carrinho em uma rota própria)
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho de Compras')),
      body: const CartContent(),
    );
  }
}

/// Conteúdo do carrinho (sem AppBar/Scaffold) para uso na Home
class CartContent extends StatelessWidget {
  const CartContent({super.key});

  /// Usa espaço não-quebrável entre "R$" e o valor para evitar quebra de linha.
  String _money(num v) =>
      'R\$ ${v.toStringAsFixed(2)}'.replaceFirst(' ', '\u00A0');

  Future<bool> _confirmRemoveItem(BuildContext context, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Remover item'),
            content: Text('Deseja remover "$name" do carrinho?'),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Remover'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    if (cart.items.isEmpty) {
      return const Center(child: Text('Seu carrinho está vazio'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              CartItem item = cart.items[index];
              final price = item.product.precoUnt;
              final quantity = item.quantity;
              final subtotal = price * quantity;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageURL,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.cientificName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _money(
                                price,
                              ), // <- NBSP evita quebra entre R$ e valor
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Subtotal:',
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  // <- NBSP também no subtotal
                                  '${_money(price)} × $quantity = ${_money(subtotal)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Stepper com área de toque ampliada
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StepButton(
                            tooltip: 'Diminuir',
                            icon: Icons.remove,
                            onPressed: () async {
                              if (quantity <= 1) {
                                final ok = await _confirmRemoveItem(
                                  context,
                                  item.product.cientificName,
                                );
                                if (ok) cart.removeFromCart(item.product);
                              } else {
                                cart.updateQuantity(item.product, quantity - 1);
                              }
                            },
                          ),
                          _QtyBadge(value: quantity),
                          _StepButton(
                            tooltip: 'Aumentar',
                            icon: Icons.add,
                            onPressed: () {
                              cart.updateQuantity(item.product, quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Rodapé: total + botão Continuar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Total: ${_money(cart.totalPrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: 'Continuar',
                icon: Icons.arrow_forward,
                backgroundColor: Colors.green,
                onPressed: () async {
                  final selectedAddress = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddressSelectionPage(),
                    ),
                  );
                  if (context.mounted && selectedAddress != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                PaymentPage(selectedAddress: selectedAddress),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botão quadrado 44x44 com bordas arredondadas (maior área de toque)
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 44,
          height: 44,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Color(0x33000000)),
            ),
            onPressed: onPressed,
            child: Icon(icon, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Exibe a quantidade com boa legibilidade e área de toque separada
class _QtyBadge extends StatelessWidget {
  const _QtyBadge({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33000000)),
      ),
      child: Text(
        '$value',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
