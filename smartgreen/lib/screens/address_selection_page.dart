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

  Color get _green => const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService(userId: 'teste');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Selecione um Endereço'),
        centerTitle: true,
        backgroundColor: _green,
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
                child:
                    addresses.isEmpty
                        ? const Center(
                          child: Text('Nenhum endereço cadastrado.'),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final address = addresses[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 3,
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
                                          onChanged:
                                              (value) => setState(
                                                () => selectedAddressId = value,
                                              ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${address.street}, ${address.city}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('CEP: ${address.cep}'),
                                    if (address.complement.isNotEmpty)
                                      Text(
                                        'Complemento: ${address.complement}',
                                      ),
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
                                            final confirm = await showDialog<
                                              bool
                                            >(
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
                                                        child: const Text(
                                                          'Cancelar',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          'Excluir',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                            if (confirm == true) {
                                              await addressService
                                                  .deleteAddress(address.id);
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
                                                    (_) => MapPage(
                                                      address: address,
                                                    ),
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

              // Barra fixa inferior com ações
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SafeArea(
                  top: false,
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
                        backgroundColor: _green,
                        textColor: Colors.white,
                        onPressed:
                            selectedAddressId == null
                                ? null
                                : () {
                                  final selected = (snapshot.data ?? [])
                                      .firstWhere(
                                        (e) => e.id == selectedAddressId,
                                      );
                                  Navigator.pop(context, selected);
                                },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
