// lib/screens/store_product_form_page.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/s3_upload_service.dart';
import 'package:mime/mime.dart';
import '../aws_s3_config.dart';
import '../models/store_product.dart';
import '../services/store_product_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/plant_card_widget.dart';
import '../widgets/leaf_glyph.dart';

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
  final _cientificNameCtrl =
      TextEditingController();
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
  final _tempMaxCtrl =
      TextEditingController();
  final _tempMinCtrl =
      TextEditingController();
  final _umidadeMaxCtrl =
      TextEditingController();
  final _umidadeMinCtrl =
      TextEditingController();
  String? _tempoSolValue;
  final _valDiasCtrl =
      TextEditingController();
  final _dataPlantioCtrl =
      TextEditingController();
  final _priceCtrl =
      TextEditingController();
  final _stockCtrl =
      TextEditingController();
  String? _catValue;
  String? _imageUrl;
  String? _localImagePath;
  bool _uploadingImage =
      false;

  bool _saving =
      false;

  @override
  void initState() {
    super.initState();
    final p = widget.storeProduct;
    if (p !=
        null) {
      _nameCtrl.text = p.nome;
      _cientificNameCtrl.text = p.cientificName;
      _descCtrl.text = p.descricaoProd;
      _descPlantaCtrl.text = p.descricaoPlanta;
      if (p.temperaturaMax !=
          null) {
        _tempMaxCtrl.text = p.temperaturaMax.toString();
      }
      if (p.temperaturaMin !=
          null) {
        _tempMinCtrl.text = p.temperaturaMin.toString();
      }
      if (p.umidadeMax !=
          null) {
        _umidadeMaxCtrl.text = p.umidadeMax.toString();
      }
      if (p.umidadeMinima !=
          null) {
        _umidadeMinCtrl.text = p.umidadeMinima.toString();
      }
      _tempoSolValue =
          p.tempoSol;
      _valDiasCtrl.text =
          p.valDias?.toString() ??
          '';
      if (p.dataPlantio !=
          null) {
        final d = p.dataPlantio!;
        _dataPlantioCtrl.text = '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
      } else {
        _dataPlantioCtrl.text = '';
      }
      _priceCtrl.text = p.precoUnt.toString();
      _stockCtrl.text =
          p.stock?.toString() ??
          '';
      _catValue =
          p.category ??
          '';
      _imageUrl =
          p.imageURL;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cientificNameCtrl.dispose();
    _descCtrl.dispose();
    _descPlantaCtrl.dispose();
    _tempMaxCtrl.dispose();
    _tempMinCtrl.dispose();
    _umidadeMaxCtrl.dispose();
    _umidadeMinCtrl.dispose();
    _valDiasCtrl.dispose();
    _dataPlantioCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _pickAndUploadImage() async {
    final picker =
        ImagePicker();
    final picked = await picker.pickImage(
      source:
          ImageSource.gallery,
    );
    if (picked ==
        null)
      return;
    final file = File(
      picked.path,
    );
    final mimeType = lookupMimeType(
      file.path,
    );
    if (mimeType !=
            'image/jpeg' &&
        mimeType !=
            'image/png') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione apenas arquivos .jpg ou .png',
          ),
        ),
      );
      return;
    }
    setState(
      () {
        _uploadingImage =
            true;
        _localImagePath =
            file.path;
      },
    );
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final url = await S3UploadService.uploadFile(
        file:
            file,
        filename:
            fileName,
        contentType:
            mimeType ??
            'image/jpeg',
      );
      setState(
        () {
          _imageUrl =
              url;
        },
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Imagem enviada com sucesso!',
          ),
        ),
      );
    } catch (
      e
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao enviar imagem: $e',
          ),
        ),
      );
    } finally {
      setState(
        () {
          _uploadingImage =
              false;
        },
      );
    }
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

    // Parse valores de temperatura e umidade
    double? tempMax = double.tryParse(
      _tempMaxCtrl.text.replaceAll(
        ',',
        '.',
      ),
    );
    double? tempMin = double.tryParse(
      _tempMinCtrl.text.replaceAll(
        ',',
        '.',
      ),
    );
    double? umiMax = double.tryParse(
      _umidadeMaxCtrl.text.replaceAll(
        ',',
        '.',
      ),
    );
    double? umiMin = double.tryParse(
      _umidadeMinCtrl.text.replaceAll(
        ',',
        '.',
      ),
    );
    String fxTemp =
        (tempMax !=
                    null &&
                tempMin !=
                    null)
            ? ((tempMax +
                        tempMin) /
                    2)
                .toStringAsFixed(
                  1,
                )
            : '';
    String fxUmidade =
        (umiMax !=
                    null &&
                umiMin !=
                    null)
            ? ((umiMax +
                        umiMin) /
                    2)
                .toStringAsFixed(
                  1,
                )
            : '';

    final p = StoreProduct(
      id:
          widget.storeProduct?.id ??
          '',
      nome:
          _nameCtrl.text.trim(),
      cientificName:
          _cientificNameCtrl.text.trim(),
      descricaoProd:
          _descCtrl.text.trim(),
      descricaoPlanta:
          _descPlantaCtrl.text.trim(),
      temperaturaMax:
          tempMax,
      temperaturaMin:
          tempMin,
      umidadeMax:
          umiMax,
      umidadeMinima:
          umiMin,
      fxTemp:
          fxTemp,
      fxUmidade:
          fxUmidade,
      tempoSol:
          _tempoSolValue ??
          '',
      valDias: int.tryParse(
        _valDiasCtrl.text.trim(),
      ),
      dataPlantio:
          dataPlantio,
      precoUnt:
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
          _catValue?.isEmpty ??
                  true
              ? null
              : _catValue,
      imageURL:
          _imageUrl ??
          '',
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

  InputDecoration _dec(
    String label,
  ) {
    final cs =
        Theme.of(
          context,
        ).colorScheme;
    return InputDecoration(
      labelText:
          label,
      filled:
          true,
      fillColor:
          cs.surface, // usa surface do tema
      isDense:
          true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal:
            12,
        vertical:
            14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: BorderSide(
          color:
              cs.outlineVariant,
          width:
              1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: BorderSide(
          color:
              cs.outlineVariant,
          width:
              1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: BorderSide(
          color:
              cs.primary,
          width:
              2,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final cs =
        Theme.of(
          context,
        ).colorScheme;
    final isEdit =
        widget.storeProduct !=
        null;

    return Scaffold(
      backgroundColor:
          Theme.of(
            context,
          ).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            cs.primary,
        foregroundColor:
            cs.onPrimary,
        centerTitle:
            true,
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
                  // Nome
                  TextFormField(
                    controller:
                        _nameCtrl,
                    decoration: _dec(
                      'Nome',
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
                  // Nome Científico (se não for insumo/ferramenta)
                  if (_catValue !=
                      'Insumo/Ferramenta') ...[
                    TextFormField(
                      controller:
                          _cientificNameCtrl,
                      decoration: _dec(
                        'Nome Científico',
                      ),
                    ),
                    const SizedBox(
                      height:
                          12,
                    ),
                  ],
                  // Categoria
                  DropdownButtonFormField<
                    String
                  >(
                    value:
                        _catValue?.isNotEmpty ==
                                true
                            ? _catValue
                            : null,
                    decoration: _dec(
                      'Categoria',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value:
                            'Planta/Semente',
                        child: Text(
                          'Planta/Semente',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'Insumo/Ferramenta',
                        child: Text(
                          'Insumo/Ferramenta',
                        ),
                      ),
                    ],
                    onChanged:
                        _saving
                            ? null
                            : (
                              v,
                            ) => setState(
                              () =>
                                  _catValue =
                                      v,
                            ),
                    validator:
                        (
                          v,
                        ) =>
                            (v ==
                                        null ||
                                    v.isEmpty)
                                ? 'Selecione a categoria'
                                : null,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  // Descrição da Planta (se não for insumo/ferramenta)
                  if (_catValue !=
                      'Insumo/Ferramenta') ...[
                    TextFormField(
                      controller:
                          _descPlantaCtrl,
                      decoration: _dec(
                        'Descrição da Planta',
                      ),
                      maxLines:
                          2,
                    ),
                    const SizedBox(
                      height:
                          12,
                    ),
                  ],
                  // Temperatura (mínima e máxima) (se não for insumo/ferramenta)
                  if (_catValue !=
                      'Insumo/Ferramenta') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller:
                                _tempMinCtrl,
                            decoration: _dec(
                              'Temperatura Mínima (°C)',
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
                                _tempMaxCtrl,
                            decoration: _dec(
                              'Temperatura Máxima (°C)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal:
                                  true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height:
                          12,
                    ),
                  ],
                  // Umidade (mínima e máxima) (se não for insumo/ferramenta)
                  if (_catValue !=
                      'Insumo/Ferramenta') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller:
                                _umidadeMinCtrl,
                            decoration: _dec(
                              'Umidade Mínima (%)',
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
                                _umidadeMaxCtrl,
                            decoration: _dec(
                              'Umidade Máxima (%)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal:
                                  true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height:
                          12,
                    ),
                  ],
                  // Tempo de Sol (se não for insumo/ferramenta)
                  if (_catValue !=
                      'Insumo/Ferramenta') ...[
                    DropdownButtonFormField<
                      String
                    >(
                      value:
                          _tempoSolValue?.isNotEmpty ==
                                  true
                              ? _tempoSolValue
                              : null,
                      decoration: _dec(
                        'Tempo de Sol',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value:
                              'Sombra',
                          child: Text(
                            'Sombra',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Meia Sombra',
                          child: Text(
                            'Meia Sombra',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Sol Pleno',
                          child: Text(
                            'Sol Pleno',
                          ),
                        ),
                      ],
                      onChanged:
                          _saving
                              ? null
                              : (
                                v,
                              ) => setState(
                                () =>
                                    _tempoSolValue =
                                        v,
                              ),
                      validator:
                          (
                            v,
                          ) =>
                              (v ==
                                          null ||
                                      v.isEmpty)
                                  ? 'Selecione o tempo de sol'
                                  : null,
                    ),
                    const SizedBox(
                      height:
                          12,
                    ),
                  ],
                  // Descrição do Produto
                  TextFormField(
                    controller:
                        _descCtrl,
                    decoration: _dec(
                      'Descrição do Produto',
                    ),
                    maxLines:
                        3,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  // Preço e Estoque
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              _priceCtrl,
                          decoration: _dec(
                            'Preço (R\$)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal:
                                true,
                          ),
                          validator: (
                            v,
                          ) {
                            final val = double.tryParse(
                              (v ??
                                      '')
                                  .replaceAll(
                                    ',',
                                    '.',
                                  ),
                            );
                            if (val ==
                                    null ||
                                val <
                                    0) {
                              return 'Informe um preço válido';
                            }
                            return null;
                          },
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
                          decoration: _dec(
                            'Estoque',
                          ),
                          keyboardType:
                              TextInputType.number,
                          validator: (
                            v,
                          ) {
                            if ((v ??
                                    '')
                                .trim()
                                .isEmpty) {
                              return null; // opcional
                            }
                            final n = int.tryParse(
                              v!.trim(),
                            );
                            if (n ==
                                    null ||
                                n <
                                    0) {
                              return 'Estoque inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  // Validade
                  TextFormField(
                    controller:
                        _valDiasCtrl,
                    decoration: _dec(
                      'Validade (dias)',
                    ),
                    keyboardType:
                        TextInputType.number,
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  // Upload de imagem
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.photo_library,
                          ),
                          label: Text(
                            _localImagePath !=
                                    null
                                ? 'Imagem selecionada'
                                : 'Selecionar imagem',
                          ),
                          onPressed:
                              _uploadingImage
                                  ? null
                                  : _pickAndUploadImage,
                        ),
                      ),
                      if (_uploadingImage)
                        const Padding(
                          padding: EdgeInsets.only(
                            left:
                                12,
                          ),
                          child: SizedBox(
                            width:
                                24,
                            height:
                                24,
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if ((_localImagePath !=
                              null ||
                          (_imageUrl !=
                                  null &&
                              _imageUrl!.isNotEmpty)) &&
                      !_uploadingImage) ...[
                    const SizedBox(
                      height:
                          12,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      child:
                          _localImagePath !=
                                  null
                              ? Image.file(
                                File(
                                  _localImagePath!,
                                ),
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
                                        _placeholderImage(),
                              )
                              : Image.network(
                                _imageUrl!,
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
                                        _placeholderImage(),
                              ),
                    ),
                    const SizedBox(
                      height:
                          8,
                    ),
                    if (_imageUrl !=
                            null &&
                        _imageUrl!.isNotEmpty)
                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(
                            Icons.delete,
                            color:
                                Colors.red,
                          ),
                          label: const Text(
                            'Remover imagem',
                            style: TextStyle(
                              color:
                                  Colors.red,
                            ),
                          ),
                          onPressed:
                              _saving
                                  ? null
                                  : () {
                                    setState(
                                      () {
                                        _imageUrl =
                                            null;
                                        _localImagePath =
                                            null;
                                      },
                                    );
                                  },
                        ),
                      ),
                  ] else if (!_uploadingImage) ...[
                    const SizedBox(
                      height:
                          12,
                    ),
                    _placeholderImage(),
                  ],
                  const SizedBox(
                    height:
                        24,
                  ),
                  CustomButton(
                    label:
                        _saving
                            ? 'Salvando...'
                            : (isEdit
                                ? 'Salvar alterações'
                                : 'Salvar'),
                    icon:
                        Icons.save,
                    backgroundColor:
                        cs.primary,
                    textColor:
                        cs.onPrimary,
                    onPressed:
                        _saving
                            ? null
                            : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    // Usa o mesmo placeholder visual da tela de Plantas
    return Container(
      height:
          160,
      width:
          double.infinity,
      alignment:
          Alignment.center,
      color:
          Colors.grey.shade100,
      child: FittedBox(
        fit:
            BoxFit.scaleDown,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const LeafGlyph(
              size:
                  40,
              color:
                  Colors.grey,
            ),
            const SizedBox(
              height:
                  4,
            ),
            const Text(
              'Imagem indisponível',
              style: TextStyle(
                color:
                    Colors.grey,
                fontSize:
                    11,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
