import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';

class PaymentPage extends StatefulWidget {
  final Address selectedAddress;

  const PaymentPage({super.key, required this.selectedAddress});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _paymentMethod = 'PIX';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final orderService = OrderService(userId: 'teste'); // depois vem do Auth

    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Escolha a forma de pagamento:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            RadioListTile(
              title: const Text('PIX'),
              value: 'PIX',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            RadioListTile(
              title: const Text('Cartão de Crédito'),
              value: 'Cartão',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            RadioListTile(
              title: const Text('Boleto'),
              value: 'Boleto',
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            const Spacer(),
            Text(
              'Total: R\$ ${cart.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Finalizar Pedido'),
              onPressed: () async {
                final order = Order(
                  id: '',
                  items: cart.items,
                  address: widget.selectedAddress,
                  paymentMethod: _paymentMethod,
                  total: cart.totalPrice,
                  createdAt: DateTime.now(),
                );

                await orderService.addOrder(order);
                cart.clearCart();

                // Verificação direta no contexto
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pedido realizado com sucesso!'),
                    ),
                  );

                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
