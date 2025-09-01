import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/supply.dart';
import '../services/supply_service.dart';
import '../widgets/custom_button.dart';

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

  late DateTime _createdAt;

  bool get _isEdit => widget.supply != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.supply!.name;
      _quantityController.text = widget.supply!.quantity.toString();
      _validityController.text = widget.supply!.validity;
      _createdAt = widget.supply!.createdAt;
    } else {
      _createdAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _validityController.dispose();
    super.dispose();
  }

  DateTime? _tryParseDdMmYyyy(String input) {
    try {
     
      return DateFormat('dd/MM/yyyy').parseStrict(input);
    } catch (_) {
      return null;
    }
  }

  String? _validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe o nome do insumo';
    if (s.length < 2) return 'Nome muito curto';
    return null;
  }

  String? _validateQty(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return 'Informe um número válido';
    if (n <= 0) return 'Quantidade deve ser maior que 0';
    return null;
  }

  String? _validateValidity(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe a data de validade (dd/MM/yyyy)';

    final parsed = _tryParseDdMmYyyy(s);
    if (parsed == null) return 'Data inválida. Use dd/MM/yyyy';

    
    final created = DateTime(_createdAt.year, _createdAt.month, _createdAt.day);
    final validity = DateTime(parsed.year, parsed.month, parsed.day);

    if (validity.isBefore(created)) {
      return 'Validade não pode ser anterior à data de criação';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final s = Supply(
      id: widget.supply?.id ?? '',
      name: _nameController.text.trim(),
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      validity: _validityController.text.trim(), 
      createdAt: _createdAt, 
      imageUrl: widget.supply?.imageUrl, 
    );

    if (_isEdit) {
      await _service.updateSupply(s);
    } else {
      await _service.addSupply(s);
    }

    if (mounted) Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: Text(_isEdit ? 'Edite as informações' : 'Cadastre um insumo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                ),
                const SizedBox(height: 12),

                
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _validateQty,
                ),
                const SizedBox(height: 12),

                
                TextFormField(
                  controller: _validityController,
                  decoration: const InputDecoration(
                    labelText: 'Validade (dd/MM/yyyy)',
                    hintText: 'Ex.: 25/12/2025',
                  ),
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.done,
                  validator: _validateValidity,
                ),

                const SizedBox(height: 24),

                
                CustomButton(
                  label: _isEdit ? 'Salvar' : 'Finalizar Cadastro',
                  icon: Icons.check_circle,
                  backgroundColor: cs.primary,
                  textColor: cs.onPrimary,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
