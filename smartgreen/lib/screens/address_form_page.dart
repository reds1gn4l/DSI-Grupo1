// lib/screens/address_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/address.dart';
import '../services/address_service.dart';
import 'map_page.dart';
import '../widgets/custom_button.dart';
import '../globals.dart';

class AddressFormPage extends StatefulWidget {
  final Address? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final cepController = TextEditingController();
  final complementController = TextEditingController();
  final stateController = TextEditingController();
  final numberController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final referenceController = TextEditingController();

  Color get _green => const Color(0xFF2E7D32);
  bool get _isEditing => widget.address != null;

  // UF válidas
  static const Set<String> _ufs = {
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  };

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    if (a != null) {
      streetController.text = a.street;
      cityController.text = a.city;
      cepController.text = a.cep;
      complementController.text = a.complement;
      stateController.text = a.state;
      numberController.text = a.number;
      neighborhoodController.text = a.neighborhood;
      referenceController.text = a.reference;
    }
  }

  @override
  void dispose() {
    streetController.dispose();
    cityController.dispose();
    cepController.dispose();
    complementController.dispose();
    stateController.dispose();
    numberController.dispose();
    neighborhoodController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  // ---------- Helpers de validação/normalização ----------
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _green, width: 2),
      ),
      counterText: '',
    );
  }

  String _onlyDigits(String s) => s.replaceAll(RegExp(r'\D'), '');

  String _formatCep(String s) {
    final digits = _onlyDigits(s);
    if (digits.length == 8) {
      return '${digits.substring(0, 5)}-${digits.substring(5)}';
    }
    return s.trim();
  }

  String? _validateCep(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe o CEP';
    if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(s)) return 'CEP inválido';
    return null;
  }

  String? _validateUF(String? v) {
    final s = (v ?? '').trim().toUpperCase();
    if (s.isEmpty) return 'UF obrigatória';
    if (s.length != 2 || !_ufs.contains(s)) return 'UF inválida';
    return null;
  }

  String? _validateCidadeBairro(String? v, String rotulo) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe $rotulo';
    if (!RegExp(r"^[A-Za-zÀ-ÿ' -]{2,}$").hasMatch(s)) {
      return '$rotulo inválido';
    }
    return null;
  }

  String? _validateStreet(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe o endereço';
    if (!RegExp(r"^[A-Za-zÀ-ÿ0-9 .,'-]{3,}$").hasMatch(s)) {
      return 'Endereço inválido';
    }
    return null;
  }

  String? _validateNumber(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe o número ou SN';
    if (s.toUpperCase() == 'SN') return null;
    if (!RegExp(r'^\d{1,6}$').hasMatch(s)) return 'Número inválido';
    return null;
  }

  String _sanitize(String s, {int? max}) {
    var r = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (max != null && r.length > max) r = r.substring(0, max);
    return r;
  }

  // ---------- Ações ----------
  Future<void> _openMap() async {
    if (!_isEditing && cepController.text.trim().isEmpty) {
      await showDialog<void>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('CEP necessário'),
              content: const Text('Preencha o CEP para visualizar no mapa.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            ),
      );
      return;
    }

    final initial = Address(
      id: widget.address?.id ?? '',
      cep: _formatCep(cepController.text),
      state: stateController.text.trim().toUpperCase(),
      city: _sanitize(cityController.text),
      neighborhood: _sanitize(neighborhoodController.text),
      street: _sanitize(streetController.text),
      number: _sanitize(numberController.text),
      complement: _sanitize(complementController.text, max: 60),
      reference: _sanitize(referenceController.text, max: 80),
      lat: widget.address?.lat,
      lng: widget.address?.lng,
    );

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPage(address: initial)),
    );

    if (updated is Address) {
      setState(() {
        cepController.text = updated.cep;
        stateController.text = updated.state;
        cityController.text = updated.city;
        neighborhoodController.text = updated.neighborhood;
        streetController.text = updated.street;
        numberController.text =
            updated.number.isEmpty ? numberController.text : updated.number;
        complementController.text = updated.complement;
        referenceController.text = updated.reference;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = getUserData()?.id ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
      );
      return;
    }

    final cepFmt = _formatCep(cepController.text);
    final uf = stateController.text.trim().toUpperCase();
    final cidade = _sanitize(cityController.text);
    final bairro = _sanitize(neighborhoodController.text);
    final rua = _sanitize(streetController.text);
    final numeroRaw = numberController.text.trim();
    final numero =
        numeroRaw.isEmpty
            ? 'SN'
            : (numeroRaw.toUpperCase() == 'SN' ? 'SN' : _sanitize(numeroRaw));
    final compl = _sanitize(complementController.text, max: 60);
    final ref = _sanitize(referenceController.text, max: 80);

    final address = Address(
      id: widget.address?.id ?? '',
      street: rua,
      city: cidade,
      cep: cepFmt,
      complement: compl,
      state: uf,
      number: numero,
      neighborhood: bairro,
      reference: ref,
      lat: widget.address?.lat,
      lng: widget.address?.lng,
    );

    final service = AddressService(userId: uid);
    if (_isEditing) {
      await service.updateAddress(address);
    } else {
      await service.addAddress(address);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Editar Endereço' : 'Novo Endereço';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: cepController,
                              maxLength: 9,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('CEP*'),
                              validator: _validateCep,
                              onChanged: (v) {
                                final d = _onlyDigits(v);
                                if (d.length <= 8) {
                                  if (d.length >= 6) {
                                    cepController.value = TextEditingValue(
                                      text:
                                          '${d.substring(0, 5)}-${d.substring(5)}',
                                      selection: TextSelection.collapsed(
                                        offset: d.length + 1,
                                      ),
                                    );
                                  } else {
                                    cepController.value = TextEditingValue(
                                      text: d,
                                      selection: TextSelection.collapsed(
                                        offset: d.length,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: stateController,
                              maxLength: 2,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [UpperCaseTextFormatter()],
                              decoration: _inputDecoration('UF*'),
                              validator: _validateUF,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cityController,
                              maxLength: 40,
                              decoration: _inputDecoration('Cidade*'),
                              validator:
                                  (v) => _validateCidadeBairro(v, 'Cidade'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: neighborhoodController,
                              maxLength: 40,
                              decoration: _inputDecoration('Bairro*'),
                              validator:
                                  (v) => _validateCidadeBairro(v, 'Bairro'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: streetController,
                        maxLength: 60,
                        decoration: _inputDecoration('Endereço*'),
                        validator: _validateStreet,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: numberController,
                              maxLength: 6,
                              decoration: _inputDecoration('Número*'),
                              validator: _validateNumber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: complementController,
                              maxLength: 60,
                              decoration: _inputDecoration('Complemento'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: referenceController,
                        maxLength: 80,
                        decoration: _inputDecoration('Referência'),
                      ),
                      const SizedBox(height: 16),

                      // Botão azul (usa o azul do tema)
                      CustomButton(
                        label: 'Visualizar no mapa',
                        icon: Icons.map,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        textColor: Colors.white,
                        onPressed: _openMap,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Barra fixa inferior com o botão verde de confirmação
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SafeArea(
              top: false,
              child: CustomButton(
                label: _isEditing ? 'Salvar Alterações' : 'Salvar Endereço',
                icon: Icons.check_circle,
                backgroundColor: _green,
                textColor: Colors.white,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formatter simples para forçar maiúsculas (ex.: UF)
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
