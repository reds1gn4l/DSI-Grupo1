// lib/screens/payment_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/order_service.dart';
import '../services/cart_service.dart';
import 'order_confirmation_page.dart';
import '../widgets/custom_button.dart';
import 'address_selection_page.dart';
import '../globals.dart';

class PaymentPage extends StatefulWidget {
  final Address selectedAddress;

  const PaymentPage({super.key, required this.selectedAddress});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _paymentMethod = 'PIX';
  late Address _selectedAddress;

  Color get _green => const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.selectedAddress;
  }

  Future<void> _finalizarPedido() async {
    final uid = getUserData()?.id;
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
      );
      return;
    }

    final cart = Provider.of<CartService>(context, listen: false);
    final orderService = OrderService(userId: uid);

    final items =
        cart.items
            .map(
              (ci) => OrderItem(
                productId: ci.product.id,
                quantity: ci.quantity,
                unitPrice: ci.product.precoUnt,
              ),
            )
            .toList();

    final order = Order(
      id: '',
      items: items,
      addressId: _selectedAddress.id, // apenas referência
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

  Future<void> _chooseAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressSelectionPage()),
    );
    if (!mounted) return;
    if (result is Address) {
      setState(() => _selectedAddress = result);
    }
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
          onChanged: (value) => setState(() => _paymentMethod = value!),
        ),
        onTap: () => setState(() => _paymentMethod = method),
      ),
    );
  }

  Widget _addressCard(Address a) {
    final title =
        StringBuffer()
          ..write(a.street)
          ..write(a.number.isNotEmpty ? ', ${a.number}' : '');
    final line2 =
        StringBuffer()
          ..write(a.neighborhood.isNotEmpty ? '${a.neighborhood} • ' : '')
          ..write(a.city)
          ..write(a.state.isNotEmpty ? '/${a.state}' : '');
    final line3 = 'CEP: ${a.cep}';
    final hasCompl = a.complement.trim().isNotEmpty;
    final hasRef = a.reference.trim().isNotEmpty;

    return InkWell(
      onTap: _chooseAddress, // trocar endereço
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(line2.toString(), style: const TextStyle(fontSize: 13)),
              Text(line3, style: const TextStyle(fontSize: 13)),
              if (hasCompl || hasRef) const SizedBox(height: 4),
              if (hasCompl)
                Text(
                  'Complemento: ${a.complement}',
                  style: const TextStyle(fontSize: 13),
                ),
              if (hasRef)
                Text(
                  'Referência: ${a.reference}',
                  style: const TextStyle(fontSize: 13),
                ),
              const SizedBox(height: 6),
              const Text(
                'Toque para escolher outro endereço',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Pagamento'),
        centerTitle: true,
        backgroundColor: _green,
        foregroundColor: Colors.white, // título e seta brancos
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                // <-- estica os filhos (Cards) para largura total
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Endereço de Entrega:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _addressCard(_selectedAddress),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SafeArea(
              top: false,
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
                    backgroundColor: _green,
                    onPressed: _finalizarPedido,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
