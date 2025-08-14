import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import 'map_page.dart';
import '../widgets/custom_button.dart';

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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService(userId: 'teste');
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Endereço' : 'Novo Endereço'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: streetController,
                decoration: _inputDecoration('Rua'),
                validator: (value) => value!.isEmpty ? 'Informe a rua' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cityController,
                decoration: _inputDecoration('Cidade'),
                validator:
                    (value) => value!.isEmpty ? 'Informe a cidade' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cepController,
                decoration: _inputDecoration('CEP'),
                validator: (value) => value!.isEmpty ? 'Informe o CEP' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: complementController,
                decoration: _inputDecoration('Complemento'),
              ),
              const SizedBox(height: 20),

              /// Botão de Mapa
              CustomButton(
                label: 'Ver/Editar no Mapa',
                icon: Icons.map,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
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

              /// Botão de Salvar/Editar
              CustomButton(
                label: isEditing ? 'Salvar Alterações' : 'Salvar Endereço',
                icon: Icons.check_circle,
                backgroundColor: Colors.green,
                textColor: Colors.white,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
