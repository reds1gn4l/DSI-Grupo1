import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../services/store_product_service.dart';

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
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description ?? '';
      _priceCtrl.text = p.price?.toString() ?? '';
      _stockCtrl.text = p.stock?.toString() ?? '';
      _catCtrl.text = p.category ?? '';
      _imgCtrl.text = p.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _catCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final p = StoreProduct(
      id: widget.storeProduct?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.replaceAll(',', '.')),
      stock: int.tryParse(_stockCtrl.text.trim()),
      category: _catCtrl.text.trim().isEmpty ? null : _catCtrl.text.trim(),
      imageUrl: _imgCtrl.text.trim().isEmpty ? null : _imgCtrl.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.storeProduct != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar produto' : 'Novo produto')),
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
                    decoration: const InputDecoration(labelText: 'Nome *'),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Informe o nome'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Preço (R\$)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Estoque',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _catCtrl,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imgCtrl,
                    decoration: const InputDecoration(
                      labelText: 'URL da imagem',
                    ),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon:
                          _saving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(
                        _saving
                            ? 'Salvando...'
                            : (isEdit ? 'Salvar alterações' : 'Salvar'),
                      ),
                    ),
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
