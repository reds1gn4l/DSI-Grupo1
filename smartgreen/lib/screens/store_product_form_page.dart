import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../services/store_product_service.dart';

class StoreProductFormPage
    extends
        StatefulWidget {
  final StoreProduct? storeProduct;
  const StoreProductFormPage({
    super.key,
    this.storeProduct,
  });

  @override
  State<
    StoreProductFormPage
  >
  createState() =>
      _ProductFormPageState();
}

class _ProductFormPageState
    extends
        State<
          StoreProductFormPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _nameCtrl =
      TextEditingController();
  final _descCtrl =
      TextEditingController();
  final _descPlantaCtrl =
      TextEditingController();
  final _fxTempCtrl =
      TextEditingController();
  final _fxUmidadeCtrl =
      TextEditingController();
  final _tempoSolCtrl =
      TextEditingController();
  final _valDiasCtrl =
      TextEditingController();
  final _dataPlantioCtrl =
      TextEditingController();
  final _priceCtrl =
      TextEditingController();
  final _stockCtrl =
      TextEditingController();
  final _catCtrl =
      TextEditingController();
  final _imgCtrl =
      TextEditingController();

  bool _saving =
      false;

  @override
  void initState() {
    super.initState();
    final p = widget.storeProduct;
    if (p !=
        null) {
      _nameCtrl.text = p.CientificName;
      _descCtrl.text = p.DescricaoProd;
      _descPlantaCtrl.text = p.DescricaoPlanta;
      _fxTempCtrl.text = p.FxTemp;
      _fxUmidadeCtrl.text = p.FxUmidade;
      _tempoSolCtrl.text = p.TempoSol;
      _valDiasCtrl.text =
          p.ValDias?.toString() ??
          '';
      if (p.DataPlantio !=
          null) {
        final d = p.DataPlantio!;
        _dataPlantioCtrl.text = '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
      } else {
        _dataPlantioCtrl.text = '';
      }
      _priceCtrl.text = p.PrecoUnt.toString();
      _stockCtrl.text =
          p.stock?.toString() ??
          '';
      _catCtrl.text =
          p.category ??
          '';
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

  Future<
    void
  >
  _save() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? dataPlantio;
    if (_dataPlantioCtrl.text.trim().isNotEmpty) {
      final parts = _dataPlantioCtrl.text.trim().split(
        '-',
      );
      if (parts.length ==
          3) {
        final day = int.tryParse(
          parts[0],
        );
        final month = int.tryParse(
          parts[1],
        );
        final year = int.tryParse(
          parts[2],
        );
        if (day !=
                null &&
            month !=
                null &&
            year !=
                null) {
          dataPlantio = DateTime(
            year,
            month,
            day,
          );
        }
      }
    }
    final p = StoreProduct(
      id:
          widget.storeProduct?.id ??
          '',
      CientificName:
          _nameCtrl.text.trim(),
      DescricaoProd:
          _descCtrl.text.trim(),
      DescricaoPlanta:
          _descPlantaCtrl.text.trim(),
      FxTemp:
          _fxTempCtrl.text.trim(),
      FxUmidade:
          _fxUmidadeCtrl.text.trim(),
      TempoSol:
          _tempoSolCtrl.text.trim(),
      ValDias: int.tryParse(
        _valDiasCtrl.text.trim(),
      ),
      DataPlantio:
          dataPlantio,
      PrecoUnt:
          double.tryParse(
            _priceCtrl.text.replaceAll(
              ',',
              '.',
            ),
          ) ??
          0.0,
      stock: int.tryParse(
        _stockCtrl.text.trim(),
      ),
      category:
          _catCtrl.text.trim().isEmpty
              ? null
              : _catCtrl.text.trim(),
      imageURL:
          _imgCtrl.text.trim().isEmpty
              ? ''
              : _imgCtrl.text.trim(),
      createdAt:
          widget.storeProduct?.createdAt,
    );

    setState(
      () =>
          _saving =
              true,
    );
    final service =
        StoreProductService();

    try {
      if (widget.storeProduct ==
          null) {
        await service.create(
          p,
        );
      } else {
        await service.update(
          p,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Produto salvo com sucesso!',
          ),
        ),
      );
      Navigator.pop(
        context,
      );
    } catch (
      e
    ) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao salvar: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () =>
              _saving =
                  false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isEdit =
        widget.storeProduct !=
        null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Editar produto'
              : 'Novo produto',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24,
          ),
          children: [
            Form(
              key:
                  _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller:
                        _nameCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Nome *',
                    ),
                    validator:
                        (
                          v,
                        ) =>
                            (v ==
                                        null ||
                                    v.trim().isEmpty)
                                ? 'Informe o nome'
                                : null,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _descCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Descrição do Produto',
                    ),
                    maxLines:
                        3,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _descPlantaCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Descrição da Planta',
                    ),
                    maxLines:
                        2,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _fxTempCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Faixa de Temperatura',
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _fxUmidadeCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Faixa de Umidade',
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _tempoSolCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Tempo de Sol',
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _valDiasCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Validade (dias)',
                    ),
                    keyboardType:
                        TextInputType.number,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _dataPlantioCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Data de Plantio (DD-MM-YYYY)',
                    ),
                    keyboardType:
                        TextInputType.datetime,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              _priceCtrl,
                          decoration: const InputDecoration(
                            labelText:
                                'Preço (R\$)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal:
                                true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width:
                            12,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller:
                              _stockCtrl,
                          decoration: const InputDecoration(
                            labelText:
                                'Estoque',
                          ),
                          keyboardType:
                              TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _catCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Categoria',
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  TextFormField(
                    controller:
                        _imgCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'URL da imagem',
                    ),
                    onChanged:
                        (
                          _,
                        ) => setState(
                          () {},
                        ),
                  ),
                  if (_imgCtrl.text.trim().isNotEmpty) ...[
                    const SizedBox(
                      height:
                          12,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      child: Image.network(
                        _imgCtrl.text.trim(),
                        height:
                            160,
                        width:
                            double.infinity,
                        fit:
                            BoxFit.cover,
                        errorBuilder:
                            (
                              _,
                              __,
                              ___,
                            ) =>
                                const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height:
                        24,
                  ),
                  SizedBox(
                    width:
                        double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _saving
                              ? null
                              : _save,
                      icon:
                          _saving
                              ? const SizedBox(
                                width:
                                    18,
                                height:
                                    18,
                                child: CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                              : const Icon(
                                Icons.save,
                              ),
                      label: Text(
                        _saving
                            ? 'Salvando...'
                            : (isEdit
                                ? 'Salvar alterações'
                                : 'Salvar'),
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
