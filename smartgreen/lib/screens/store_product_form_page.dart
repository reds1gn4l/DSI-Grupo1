// lib/screens/store_product_form_page.dart
import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../services/store_product_service.dart';
import '../widgets/custom_button.dart';

class StoreProductFormPage extends StatefulWidget {
  final StoreProduct? storeProduct;
  const StoreProductFormPage({super.key, this.storeProduct});

  @override
  State<StoreProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<StoreProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _descPlantaCtrl = TextEditingController();
  final _fxTempCtrl = TextEditingController();
  final _fxUmidadeCtrl = TextEditingController();
  final _tempoSolCtrl = TextEditingController();
  final _valDiasCtrl = TextEditingController();
  final _dataPlantioCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.storeProduct;
    if (p != null) {
      _nameCtrl.text = p.cientificName;
      _descCtrl.text = p.descricaoProd;
      _descPlantaCtrl.text = p.descricaoPlanta;
      _fxTempCtrl.text = p.fxTemp;
      _fxUmidadeCtrl.text = p.fxUmidade;
      _tempoSolCtrl.text = p.tempoSol;
      _valDiasCtrl.text = p.valDias?.toString() ?? '';
      if (p.dataPlantio != null) {
        final d = p.dataPlantio!;
        _dataPlantioCtrl.text =
            '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
      } else {
        _dataPlantioCtrl.text = '';
      }
      _priceCtrl.text = p.precoUnt.toString();
      _stockCtrl.text = p.stock?.toString() ?? '';
      _catCtrl.text = p.category ?? '';
      _imgCtrl.text = p.imageURL;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _descPlantaCtrl.dispose();
    _fxTempCtrl.dispose();
    _fxUmidadeCtrl.dispose();
    _tempoSolCtrl.dispose();
    _valDiasCtrl.dispose();
    _dataPlantioCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _catCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? dataPlantio;
    if (_dataPlantioCtrl.text.trim().isNotEmpty) {
      final parts = _dataPlantioCtrl.text.trim().split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          dataPlantio = DateTime(year, month, day);
        }
      }
    }

    final p = StoreProduct(
      id: widget.storeProduct?.id ?? '',
      cientificName: _nameCtrl.text.trim(),
      descricaoProd: _descCtrl.text.trim(),
      descricaoPlanta: _descPlantaCtrl.text.trim(),
      fxTemp: _fxTempCtrl.text.trim(),
      fxUmidade: _fxUmidadeCtrl.text.trim(),
      tempoSol: _tempoSolCtrl.text.trim(),
      valDias: int.tryParse(_valDiasCtrl.text.trim()),
      dataPlantio: dataPlantio,
      precoUnt: double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0.0,
      stock: int.tryParse(_stockCtrl.text.trim()),
      category: _catCtrl.text.trim().isEmpty ? null : _catCtrl.text.trim(),
      imageURL: _imgCtrl.text.trim().isEmpty ? '' : _imgCtrl.text.trim(),
      createdAt: widget.storeProduct?.createdAt,
    );

    setState(() => _saving = true);
    final service = StoreProductService();

    try {
      if (widget.storeProduct == null) {
        await service.create(p);
      } else {
        await service.update(p);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto salvo com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao salvar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: cs.surface, // usa surface do tema
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.storeProduct != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        centerTitle: true,
        title: Text(isEdit ? 'Editar produto' : 'Novo produto'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _dec('Nome *'),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Informe o nome'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: _dec('Descrição do Produto'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descPlantaCtrl,
                    decoration: _dec('Descrição da Planta'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fxTempCtrl,
                    decoration: _dec('Faixa de Temperatura'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fxUmidadeCtrl,
                    decoration: _dec('Faixa de Umidade'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tempoSolCtrl,
                    decoration: _dec('Tempo de Sol'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _valDiasCtrl,
                    decoration: _dec('Validade (dias)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dataPlantioCtrl,
                    decoration: _dec('Data de Plantio (DD-MM-YYYY)'),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          decoration: _dec('Preço (R\$)'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            final val = double.tryParse(
                              (v ?? '').replaceAll(',', '.'),
                            );
                            if (val == null || val < 0) {
                              return 'Informe um preço válido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockCtrl,
                          decoration: _dec('Estoque'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if ((v ?? '').trim().isEmpty) {
                              return null; // opcional
                            }
                            final n = int.tryParse(v!.trim());
                            if (n == null || n < 0) return 'Estoque inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _catCtrl,
                    decoration: _dec('Categoria'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imgCtrl,
                    decoration: _dec('URL da imagem'),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_imgCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imgCtrl.text.trim(),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    label:
                        _saving
                            ? 'Salvando...'
                            : (isEdit ? 'Salvar alterações' : 'Salvar'),
                    icon: Icons.save,
                    backgroundColor: cs.primary,
                    textColor: cs.onPrimary,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
