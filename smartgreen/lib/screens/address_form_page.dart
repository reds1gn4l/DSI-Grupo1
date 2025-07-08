import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressFormPage extends StatefulWidget {
  final Address? address; // Parâmetro opcional para edição

  const AddressFormPage({super.key, this.address}); // Adicione este parâmetro

  @override
  State<AddressFormPage> createState() => _AddressFormPageState(); // Corrija o nome do State
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
    // Preenche os campos se estiver editando
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
    final isEditing = widget.address != null; // Verifica modo edição

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Endereço' : 'Novo Endereço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Rua'),
                validator: (value) => value!.isEmpty ? 'Informe a rua' : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator:
                    (value) => value!.isEmpty ? 'Informe a cidade' : null,
              ),
              TextFormField(
                controller: cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                validator: (value) => value!.isEmpty ? 'Informe o CEP' : null,
              ),
              TextFormField(
                controller: complementController,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final address = Address(
                      id:
                          widget.address?.id ??
                          '', // Mantém ID se estiver editando
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
