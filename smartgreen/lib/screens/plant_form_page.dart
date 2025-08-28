// lib/screens/plant_form_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../widgets/custom_button.dart';

class PlantFormPage extends StatefulWidget {
  final Plant? plant;

  const PlantFormPage({super.key, this.plant});

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _tempMinController = TextEditingController();
  final _tempMaxController = TextEditingController();
  final _umidadeMinController = TextEditingController();
  final _umidadeMaxController = TextEditingController();

  late DateTime _dataPlantio;

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _nameController.text = widget.plant!.name;
      _tempMinController.text = widget.plant!.temperaturaMin?.toString() ?? '';
      _tempMaxController.text = widget.plant!.temperaturaMax?.toString() ?? '';
      _umidadeMinController.text = widget.plant!.umidadeMin?.toString() ?? '';
      _umidadeMaxController.text = widget.plant!.umidadeMax?.toString() ?? '';
      _dataPlantio = widget.plant!.dataPlantio ?? DateTime.now();
    } else {
      _dataPlantio = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _umidadeMinController.dispose();
    _umidadeMaxController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? v, String label) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe $label';
    return null;
  }

  String? _validateInt(String? v, String label) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // opcional
    final n = int.tryParse(s);
    if (n == null) return '$label inválida';
    return null;
  }

  int? _toInt(String text) {
    final s = text.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    // Regras de coerência entre mínimos e máximos (se ambos informados)
    final tMin = _toInt(_tempMinController.text);
    final tMax = _toInt(_tempMaxController.text);
    final uMin = _toInt(_umidadeMinController.text);
    final uMax = _toInt(_umidadeMaxController.text);

    if (tMin != null && tMax != null && tMin > tMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Temperatura mín. não pode ser maior que a máx.'),
        ),
      );
      return;
    }
    if (uMin != null && uMax != null && uMin > uMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Umidade mín. não pode ser maior que a máx.'),
        ),
      );
      return;
    }

    final plant = Plant(
      id: widget.plant?.id ?? '',
      name: _nameController.text.trim(),
      temperaturaMin: tMin,
      temperaturaMax: tMax,
      umidadeMin: uMin,
      umidadeMax: uMax,
      dataPlantio: _dataPlantio,
      status: widget.plant?.status ?? 'cinza',
    );

    if (widget.plant == null) {
      await PlantService().addPlant(plant);
    } else {
      await PlantService().updatePlant(plant);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headerTitle =
        widget.plant == null ? 'Cadastrar Planta' : 'Editar Planta';

    return Scaffold(
      appBar: AppBar(
        title: Text(headerTitle),
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Column(
        children: [
          // Conteúdo rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nome
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da planta*',
                      ),
                      validator:
                          (v) => _validateRequired(v, 'o nome da planta'),
                    ),
                    const SizedBox(height: 12),

                    // Temperatura min / max
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tempMinController,
                            decoration: const InputDecoration(
                              labelText: 'Temperatura mín. (°C)',
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (v) => _validateInt(v, 'Temperatura mín.'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _tempMaxController,
                            decoration: const InputDecoration(
                              labelText: 'Temperatura máx. (°C)',
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (v) => _validateInt(v, 'Temperatura máx.'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Umidade min / max
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _umidadeMinController,
                            decoration: const InputDecoration(
                              labelText: 'Umidade mín. (%)',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateInt(v, 'Umidade mín.'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _umidadeMaxController,
                            decoration: const InputDecoration(
                              labelText: 'Umidade máx. (%)',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => _validateInt(v, 'Umidade máx.'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Data de plantio
                    Row(
                      children: [
                        const Text(
                          'Data de plantio: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(DateFormat('dd/MM/yyyy').format(_dataPlantio)),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Selecionar'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dataPlantio,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (!mounted) return;
                            if (picked != null) {
                              setState(() => _dataPlantio = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Rodapé fixo com botão salvar (padrão do app)
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
                label: widget.plant == null ? 'Salvar' : 'Salvar alterações',
                icon: Icons.check_circle,
                backgroundColor: cs.primary,
                textColor: cs.onPrimary,
                onPressed: _savePlant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
