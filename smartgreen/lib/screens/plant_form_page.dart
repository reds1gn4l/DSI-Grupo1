import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/store_product_service.dart';
import '../models/store_product.dart';
import 'dart:async';
import '../globals.dart';

class PlantFormPage
    extends
        StatefulWidget {
  final Plant? existingPlant;
  const PlantFormPage({
    super.key,
    this.existingPlant,
  });

  @override
  State<
    PlantFormPage
  >
  createState() =>
      _PlantFormPageState();
}

class _PlantFormPageState
    extends
        State<
          PlantFormPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _service =
      PlantService();

  final _nameController =
      TextEditingController();
  final _tempMinController =
      TextEditingController();
  final _tempMaxController =
      TextEditingController();
  final _umidMinController =
      TextEditingController();
  final _umidMaxController =
      TextEditingController();
  String? _tempMaxError;
  String? _umidMaxError;
  final FocusNode _nameFocus =
      FocusNode();
  final StoreProductService _storeService =
      StoreProductService();
  List<
    StoreProduct
  >
  _suggestions =
      <
        StoreProduct
      >[];
  bool _loadingSuggestions =
      false;
  Timer? _debounce;
  static const List<
    String
  >
  _lightOptions = <
    String
  >[
    'Sol Pleno',
    'Meia Sombra',
    'Sombra',
  ];
  String? _selectedLight;
  String? _normalizeLight(
    String? v,
  ) {
    if (v ==
        null)
      return null;
    final s = v.trim().toLowerCase();
    if (s ==
            'sol pleno' ||
        s ==
            'sol_pleno')
      return 'Sol Pleno';
    if (s ==
            'meia sombra' ||
        s ==
            'meia_sombra')
      return 'Meia Sombra';
    if (s ==
        'sombra')
      return 'Sombra';
    return _lightOptions.contains(
          v,
        )
        ? v
        : null;
  }

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(
      () {
        if (!_nameFocus.hasFocus) {
          setState(
            () =>
                _suggestions =
                    <
                      StoreProduct
                    >[],
          );
        }
      },
    );
    final p = widget.existingPlant;
    if (p !=
        null) {
      _nameController.text = p.name;
      _tempMinController.text =
          p.temperaturaMin?.toString() ??
          '';
      _tempMaxController.text =
          p.temperaturaMax?.toString() ??
          '';
      _umidMinController.text =
          p.umidadeMin?.toString() ??
          '';
      _umidMaxController.text =
          p.umidadeMax?.toString() ??
          '';
      _selectedLight =
          _normalizeLight(
            p.exposicaoSolar,
          ) ??
          _lightOptions.first;
      _selectedDate =
          p.dataPlantio ??
          DateTime.now();
    } else {
      _selectedDate =
          DateTime.now();
      _selectedLight =
          _lightOptions.first;
    }
    // Validação cruzada inline: define listeners e revalidações
    void revalidateTemp() {
      final tmin = int.tryParse(
        _tempMinController.text.trim(),
      );
      final tmax = int.tryParse(
        _tempMaxController.text.trim(),
      );
      final err =
          (tmin !=
                      null &&
                  tmax !=
                      null &&
                  tmax <=
                      tmin)
              ? 'Temperatura Máx deve ser maior que a Mín'
              : null;
      if (_tempMaxError !=
          err) {
        setState(
          () =>
              _tempMaxError =
                  err,
        );
      }
    }

    void revalidateUmid() {
      final umin = int.tryParse(
        _umidMinController.text.trim(),
      );
      final umax = int.tryParse(
        _umidMaxController.text.trim(),
      );
      final err =
          (umin !=
                      null &&
                  umax !=
                      null &&
                  umax <=
                      umin)
              ? 'Umidade Máx deve ser maior que a Mín'
              : null;
      if (_umidMaxError !=
          err) {
        setState(
          () =>
              _umidMaxError =
                  err,
        );
      }
    }

    _tempMinController.addListener(
      revalidateTemp,
    );
    _tempMaxController.addListener(
      revalidateTemp,
    );
    _umidMinController.addListener(
      revalidateUmid,
    );
    _umidMaxController.addListener(
      revalidateUmid,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isEditing =
        widget.existingPlant !=
        null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Editar Planta'
              : 'Nova Planta',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Form(
          key:
              _formKey,
          autovalidateMode:
              AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller:
                    _nameController,
                focusNode:
                    _nameFocus,
                decoration: const InputDecoration(
                  labelText:
                      'Nome da Planta',
                ),
                onChanged: (
                  value,
                ) {
                  _debounce?.cancel();
                  if (value.trim().length <
                      3) {
                    setState(
                      () =>
                          _suggestions =
                              <
                                StoreProduct
                              >[],
                    );
                    return;
                  }
                  _debounce = Timer(
                    const Duration(
                      milliseconds:
                          300,
                    ),
                    () async {
                      setState(
                        () =>
                            _loadingSuggestions =
                                true,
                      );
                      try {
                        final results = await _storeService.searchByCategoryAndQuery(
                          category:
                              'Planta/Semente',
                          query:
                              value,
                          limit:
                              8,
                        );
                        if (mounted) {
                          setState(
                            () {
                              _suggestions =
                                  results;
                            },
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(
                            () =>
                                _loadingSuggestions =
                                    false,
                          );
                        }
                      }
                    },
                  );
                },
                validator: (
                  value,
                ) {
                  if (value ==
                          null ||
                      value.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  final nameRegex = RegExp(
                    r'^[A-Za-zÀ-ÿ\s]+$',
                  );
                  if (!nameRegex.hasMatch(
                    value,
                  )) {
                    return 'Use apenas letras e acentos';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height:
                    12,
              ),
              // Sugestões de produtos (autocomplete)
              if (_loadingSuggestions)
                const Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        8,
                  ),
                  child: LinearProgressIndicator(
                    minHeight:
                        2,
                  ),
                ),
              if (_suggestions.isNotEmpty)
                Card(
                  elevation:
                      2,
                  margin: const EdgeInsets.only(
                    bottom:
                        12,
                  ),
                  child: ListView.builder(
                    shrinkWrap:
                        true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        _suggestions.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final s = _suggestions[index];
                      return ListTile(
                        leading:
                            s.imageURL.isNotEmpty
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    s.imageURL,
                                  ),
                                )
                                : const CircleAvatar(
                                  child: Icon(
                                    Icons.local_florist,
                                  ),
                                ),
                        title: Text(
                          s.nome,
                        ),
                        subtitle: Text(
                          s.cientificName,
                        ),
                        onTap: () {
                          // Preenche os demais campos
                          _nameController.text = s.nome;
                          if (s.temperaturaMin !=
                              null) {
                            _tempMinController.text = s.temperaturaMin!.round().toString();
                          }
                          if (s.temperaturaMax !=
                              null) {
                            _tempMaxController.text = s.temperaturaMax!.round().toString();
                          }
                          if (s.umidadeMinima !=
                              null) {
                            _umidMinController.text = s.umidadeMinima!.round().toString();
                          }
                          if (s.umidadeMax !=
                              null) {
                            _umidMaxController.text = s.umidadeMax!.round().toString();
                          }
                          _selectedLight =
                              _normalizeLight(
                                s.tempoSol,
                              ) ??
                              _selectedLight;
                          setState(
                            () {
                              _suggestions =
                                  <
                                    StoreProduct
                                  >[];
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:
                          _tempMinController,
                      decoration: const InputDecoration(
                        labelText:
                            'Temp. Mín (°C)',
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (
                        value,
                      ) {
                        final v = int.tryParse(
                          value ??
                              '',
                        );
                        if (v ==
                            null) {
                          return 'Número inválido';
                        }
                        if (v <
                                -50 ||
                            v >
                                70) {
                          return 'Mín: -50 a 70 °C';
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
                          _tempMaxController,
                      decoration: const InputDecoration(
                        labelText:
                            'Temp. Máx (°C)',
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (
                        value,
                      ) {
                        final v = int.tryParse(
                          value ??
                              '',
                        );
                        if (v ==
                            null) {
                          return 'Número inválido';
                        }
                        if (v <
                                -50 ||
                            v >
                                70) {
                          return 'Máx: -50 a 70 °C';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_tempMaxError !=
                  null)
                Padding(
                  padding: const EdgeInsets.only(
                    top:
                        4,
                    bottom:
                        4,
                  ),
                  child: Align(
                    alignment:
                        Alignment.centerRight,
                    child: Text(
                      _tempMaxError!,
                      style: TextStyle(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.error,
                        fontSize:
                            12,
                      ),
                    ),
                  ),
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
                          _umidMinController,
                      decoration: const InputDecoration(
                        labelText:
                            'Umid. Mín (%)',
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (
                        value,
                      ) {
                        final v = int.tryParse(
                          value ??
                              '',
                        );
                        if (v ==
                            null) {
                          return 'Número inválido';
                        }
                        if (v <
                                0 ||
                            v >
                                100) {
                          return 'Mín: 0 a 100%';
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
                          _umidMaxController,
                      decoration: const InputDecoration(
                        labelText:
                            'Umid. Máx (%)',
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (
                        value,
                      ) {
                        final v = int.tryParse(
                          value ??
                              '',
                        );
                        if (v ==
                            null) {
                          return 'Número inválido';
                        }
                        if (v <
                                0 ||
                            v >
                                100) {
                          return 'Máx: 0 a 100%';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_umidMaxError !=
                  null)
                Padding(
                  padding: const EdgeInsets.only(
                    top:
                        4,
                    bottom:
                        4,
                  ),
                  child: Align(
                    alignment:
                        Alignment.centerRight,
                    child: Text(
                      _umidMaxError!,
                      style: TextStyle(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.error,
                        fontSize:
                            12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height:
                    12,
              ),
              DropdownButtonFormField<
                String
              >(
                value:
                    _selectedLight,
                decoration: const InputDecoration(
                  labelText:
                      'Exposição Solar',
                ),
                items:
                    _lightOptions
                        .map(
                          (
                            e,
                          ) => DropdownMenuItem(
                            value:
                                e,
                            child: Text(
                              e,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (
                      v,
                    ) => setState(
                      () =>
                          _selectedLight =
                              v,
                    ),
              ),
              const SizedBox(
                height:
                    12,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data de plantio: ${DateFormat('dd/MM/yyyy').format(_selectedDate ?? DateTime.now())}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_today,
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context:
                            context,
                        initialDate:
                            _selectedDate ??
                            DateTime.now(),
                        firstDate: DateTime(
                          2000,
                        ),
                        lastDate: DateTime(
                          2100,
                        ),
                      );
                      if (date !=
                          null) {
                        setState(
                          () =>
                              _selectedDate =
                                  date,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(
                height:
                    24,
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.save,
                ),
                label: const Text(
                  'Salvar',
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user =
                        currentUser;
                    if (user ==
                            null ||
                        (user.id ==
                                null ||
                            user.id!.isEmpty)) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Faça login para salvar a planta.',
                          ),
                        ),
                      );
                      return;
                    }
                    // Cross-field validation: Máx deve ser maior que Mín
                    final tmin = int.tryParse(
                      _tempMinController.text.trim(),
                    );
                    final tmax = int.tryParse(
                      _tempMaxController.text.trim(),
                    );
                    if (tmin !=
                            null &&
                        tmax !=
                            null &&
                        tmax <=
                            tmin) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Temperatura Máx deve ser maior que a Mín',
                          ),
                        ),
                      );
                      return;
                    }
                    final umin = int.tryParse(
                      _umidMinController.text.trim(),
                    );
                    final umax = int.tryParse(
                      _umidMaxController.text.trim(),
                    );
                    if (umin !=
                            null &&
                        umax !=
                            null &&
                        umax <=
                            umin) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Umidade Máx deve ser maior que a Mín',
                          ),
                        ),
                      );
                      return;
                    }
                    final plant = Plant(
                      id:
                          widget.existingPlant?.id ??
                          '',
                      name:
                          _nameController.text.trim(),
                      temperaturaMin: int.tryParse(
                        _tempMinController.text,
                      ),
                      temperaturaMax: int.tryParse(
                        _tempMaxController.text,
                      ),
                      umidadeMin: int.tryParse(
                        _umidMinController.text,
                      ),
                      umidadeMax: int.tryParse(
                        _umidMaxController.text,
                      ),
                      exposicaoSolar:
                          _selectedLight,
                      dataPlantio:
                          _selectedDate,
                      status:
                          'verde',
                      userId:
                          user.id,
                    );

                    if (isEditing) {
                      await _service.updatePlant(
                        plant,
                      );
                    } else {
                      await _service.createPlant(
                        plant,
                      );
                    }

                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pop();
                    }
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
