import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../models/address.dart';
import 'address_form_page.dart';
import 'payment_page.dart';
import '../widgets/custom_button.dart';

class AddressSelectionPage extends StatefulWidget {
  final bool cameFromCart;
  final Address? initialSelectedAddress;

  const AddressSelectionPage({
    super.key,
    this.cameFromCart = false,
    this.initialSelectedAddress,
  });

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedAddress != null) {
      selectedAddressId = widget.initialSelectedAddress!.id;
    }
  }

  Future<void> _confirmDelete(Address address, AddressService service) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_forever, color: Colors.red, size: 36),
                const SizedBox(height: 8),
                const Text(
                  'Excluir endereço?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${address.street}, ${address.city}\nCEP: ${address.cep}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
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
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Excluir'),
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

    if (confirmed == true) {
      await service.deleteAddress(address.id);
      if (selectedAddressId == address.id) {
        setState(() {
          selectedAddressId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService(userId: 'teste');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (widget.cameFromCart && !didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selecione um Endereço'),
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder<List<Address>>(
          stream: addressService.getAddresses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar endereços'));
            }

            final addresses = snapshot.data ?? [];

            return Column(
              children: [
                // Lista de endereços com o botão "Adicionar Novo Endereço" no final
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 16,
                    ),
                    itemCount: addresses.length + 1,
                    itemBuilder: (context, index) {
                      // Último item: botão "Adicionar Novo Endereço"
                      if (index == addresses.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: CustomButton(
                            label: 'Adicionar Novo Endereço',
                            icon: Icons.add,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const AddressFormPage(address: null),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      final address = addresses[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Editar ao tocar no card
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AddressFormPage(address: address),
                              ),
                            );
                          },
                          onLongPress: () {
                            // Excluir ao manter pressionado (menu de confirmação)
                            _confirmDelete(address, addressService);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: address.id,
                                      groupValue: selectedAddressId,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAddressId = value;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${address.street}, ${address.city}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('CEP: ${address.cep}'),
                                if (address.complement.isNotEmpty)
                                  Text('Complemento: ${address.complement}'),
                                const SizedBox(height: 4),
                                const Text(
                                  'Toque para editar · Pressione e segure para excluir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
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

                // Rodapé com o botão "Confirmar Endereço" (inalterado)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomButton(
                        label: 'Confirmar Endereço',
                        icon: Icons.check_circle,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        onPressed:
                            selectedAddressId == null
                                ? null
                                : () {
                                  final selected = addresses.firstWhere(
                                    (element) =>
                                        element.id == selectedAddressId,
                                  );

                                  if (widget.cameFromCart) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => PaymentPage(
                                              selectedAddress: selected,
                                            ),
                                      ),
                                    );
                                  } else {
                                    Navigator.pop(context, selected);
                                  }
                                },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
