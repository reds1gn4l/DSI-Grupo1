import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import 'map_page.dart'; // Adicionado

class AddressFormPage extends StatefulWidget {
  final Address? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final cepController = TextEditingController();
  final complementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      streetController.text = widget.address!.street;
      cityController.text = widget.address!.city;
      cepController.text = widget.address!.cep;
      complementController.text = widget.address!.complement;
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService(userId: 'teste');
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Endereço' : 'Novo Endereço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Rua'),
                validator: (value) => value!.isEmpty ? 'Informe a rua' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator:
                    (value) => value!.isEmpty ? 'Informe a cidade' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                validator: (value) => value!.isEmpty ? 'Informe o CEP' : null,
              ),
              const SizedBox(height: 10),

              /// BOTÃO PARA ABRIR O MAPA E EDITAR O CEP
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Ver/Editar no Mapa'),
                onPressed: () async {
                  final updatedAddress = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MapPage(
                            address: Address(
                              id: widget.address?.id ?? '',
                              street: streetController.text,
                              city: cityController.text,
                              cep: cepController.text,
                              complement: complementController.text,
                            ),
                          ),
                    ),
                  );

                  if (updatedAddress != null && updatedAddress is Address) {
                    setState(() {
                      streetController.text = updatedAddress.street;
                      cityController.text = updatedAddress.city;
                      cepController.text = updatedAddress.cep;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              /// BOTÃO DE SALVAR
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final address = Address(
                      id: widget.address?.id ?? '',
                      street: streetController.text,
                      city: cityController.text,
                      cep: cepController.text,
                      complement: complementController.text,
                    );

                    if (isEditing) {
                      await addressService.updateAddress(address);
                    } else {
                      await addressService.addAddress(address);
                    }

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Text(
                  isEditing ? 'Salvar Alterações' : 'Salvar Endereço',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
