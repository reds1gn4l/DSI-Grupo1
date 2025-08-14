import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';
import 'order_confirmation_page.dart';
import '../widgets/custom_button.dart';

class PaymentPage extends StatefulWidget {
  final Address selectedAddress;

  const PaymentPage({super.key, required this.selectedAddress});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _paymentMethod = 'PIX';

  Future<void> _finalizarPedido() async {
    final cart = Provider.of<CartService>(context, listen: false);
    final orderService = OrderService(userId: 'teste');

    final order = Order(
      id: '',
      items: cart.items,
      address: widget.selectedAddress,
      paymentMethod: _paymentMethod,
      total: cart.totalPrice,
      createdAt: DateTime.now(),
    );

    final orderId = await orderService.addOrder(order);
    cart.clearCart();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationPage(orderId: orderId),
      ),
    );
  }

  Widget _buildPaymentOption(String method, String label, String iconPath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset(iconPath, width: 48, height: 48),
        title: Text(label),
        trailing: Radio<String>(
          value: method,
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
        onTap: () {
          setState(() {
            _paymentMethod = method;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Endereço de Entrega:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.selectedAddress.street}, ${widget.selectedAddress.city}\nCEP: ${widget.selectedAddress.cep}\n${widget.selectedAddress.complement}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Escolha a forma de pagamento:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption('PIX', 'PIX', 'assets/icons/pix.png'),
                  _buildPaymentOption(
                    'Cartão',
                    'Cartão de Crédito',
                    'assets/icons/cartao_credito.png',
                  ),
                  _buildPaymentOption(
                    'Boleto',
                    'Boleto',
                    'assets/icons/boleto.png',
                  ),
                ],
              ),
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Finalizar Pedido',
                  icon: Icons.check_circle,
                  backgroundColor: Colors.green,
                  onPressed: _finalizarPedido,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'Cancelar',
                  icon: Icons.cancel,
                  backgroundColor: Colors.red,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
