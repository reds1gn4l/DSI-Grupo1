import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../models/address.dart';
import 'new_address_page.dart';
import 'map_page.dart'; // Adicione esta importação para o MapPage

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  String? selectedAddressId;

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService(
      userId: 'teste',
    ); // substitua pelo UID real no futuro

    return Scaffold(
      appBar: AppBar(title: const Text('Selecione um Endereço')),
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
                    return RadioListTile(
                      title: Text('${address.street}, ${address.city}'),
                      subtitle: Text(
                        'CEP: ${address.cep}\n${address.complement}',
                      ),
                      value: address.id,
                      groupValue: selectedAddressId,
                      onChanged: (value) {
                        setState(() {
                          selectedAddressId = value.toString();
                        });
                      },
                      // Novo botão de mapa adicionado aqui
                      secondary: IconButton(
                        icon: const Icon(Icons.map),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapPage(address: address),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Novo Endereço'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewAddressPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          selectedAddressId == null
                              ? null
                              : () {
                                final selected = addresses.firstWhere(
                                  (element) => element.id == selectedAddressId,
                                );
                                Navigator.pop(context, selected);
                              },
                      child: const Text('Confirmar Endereço'),
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
