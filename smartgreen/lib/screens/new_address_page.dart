import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class NewAddressPage extends StatefulWidget {
  const NewAddressPage({super.key});

  @override
  State<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final cepController = TextEditingController();
  final complementController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addressService = AddressService(userId: 'teste');

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Endereço')),
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
                      id: '',
                      street: streetController.text,
                      city: cityController.text,
                      cep: cepController.text,
                      complement: complementController.text,
                    );
                    await addressService.addAddress(address);

                    // Verificação crítica: contexto ainda válido?
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Salvar Endereço'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
