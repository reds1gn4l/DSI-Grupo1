import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../models/address.dart';
import 'address_form_page.dart';
import 'map_page.dart';
import '../widgets/custom_button.dart';

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  String? selectedAddressId;

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService(userId: 'teste');

    return Scaffold(
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
              Expanded(
                child: ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => AddressFormPage(
                                              address: address,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text(
                                              'Excluir endereço',
                                            ),
                                            content: const Text(
                                              'Deseja realmente excluir este endereço?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text('Excluir'),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirm == true) {
                                      await addressService.deleteAddress(
                                        address.id,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.map,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => MapPage(address: address),
                                      ),
                                    );
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: 'Adicionar Novo Endereço',
                      icon: Icons.add,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => const AddressFormPage(address: null),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
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
                                  (element) => element.id == selectedAddressId,
                                );
                                Navigator.pop(context, selected);
                              },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
