import 'package:flutter/material.dart';
import '../models/supply.dart';
import '../services/supply_service.dart';

class SupplyFormPage extends StatefulWidget {
  final Supply? supply;

  const SupplyFormPage({super.key, this.supply});

  @override
  State<SupplyFormPage> createState() => _SupplyFormPageState();
}

class _SupplyFormPageState extends State<SupplyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _validityController = TextEditingController();

  final _service = SupplyService();

  @override
  void initState() {
    super.initState();
    if (widget.supply != null) {
      _nameController.text = widget.supply!.name;
      _quantityController.text = widget.supply!.quantity.toString();
      _validityController.text = widget.supply!.validity;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newSupply = Supply(
      id: widget.supply?.id ?? '',
      name: _nameController.text,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      validity: _validityController.text,
    );

    if (widget.supply == null) {
      await _service.addSupply(newSupply);
    } else {
      await _service.updateSupply(newSupply);
    }

    // CORREÇÃO DEFINITIVA AQUI (usar mounted do State)
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supply != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edite as informações' : 'Cadastre um insumo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o nome'
                            : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe a quantidade'
                            : null,
              ),
              TextFormField(
                controller: _validityController,
                decoration: const InputDecoration(labelText: 'Validade'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe a validade'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? 'Salvar' : 'Finalizar Cadastro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
