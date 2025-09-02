import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';

class PlantFormPage extends StatefulWidget {
  final Plant? existingPlant;
  const PlantFormPage({super.key, this.existingPlant});

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PlantService();

  final _nameController = TextEditingController();
  final _tempMinController = TextEditingController();
  final _tempMaxController = TextEditingController();
  final _umidMinController = TextEditingController();
  final _umidMaxController = TextEditingController();
  String? _selectedLight;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPlant;
    if (p != null) {
      _nameController.text = p.name;
      _tempMinController.text = p.temperaturaMin?.toString() ?? '';
      _tempMaxController.text = p.temperaturaMax?.toString() ?? '';
      _umidMinController.text = p.umidadeMin?.toString() ?? '';
      _umidMaxController.text = p.umidadeMax?.toString() ?? '';
      _selectedLight = p.exposicaoSolar;
      _selectedDate = p.dataPlantio ?? DateTime.now();
    } else {
      _selectedDate = DateTime.now();
      _selectedLight = 'Sol pleno';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPlant != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Planta' : 'Nova Planta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Planta'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  final nameRegex = RegExp(r'^[A-Za-zÀ-ÿ\s]+$');
                  if (!nameRegex.hasMatch(value)) {
                    return 'Use apenas letras e acentos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempMinController,
                      decoration: const InputDecoration(
                        labelText: 'Temp. Mín (°C)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final v = int.tryParse(value ?? '');
                        if (v == null) return 'Número inválido';
                        if (v < -50 || v > 70) return 'Mín: -50 a 70 °C';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tempMaxController,
                      decoration: const InputDecoration(
                        labelText: 'Temp. Máx (°C)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final v = int.tryParse(value ?? '');
                        if (v == null) return 'Número inválido';
                        if (v < -50 || v > 70) return 'Máx: -50 a 70 °C';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _umidMinController,
                      decoration: const InputDecoration(
                        labelText: 'Umid. Mín (%)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final v = int.tryParse(value ?? '');
                        if (v == null) return 'Número inválido';
                        if (v < 0 || v > 100) return 'Mín: 0 a 100%';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _umidMaxController,
                      decoration: const InputDecoration(
                        labelText: 'Umid. Máx (%)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final v = int.tryParse(value ?? '');
                        if (v == null) return 'Número inválido';
                        if (v < 0 || v > 100) return 'Máx: 0 a 100%';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLight,
                decoration: const InputDecoration(labelText: 'Exposição Solar'),
                items:
                    ['Sol pleno', 'Meia sombra', 'Sombra']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedLight = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data de plantio: ${DateFormat('dd/MM/yyyy').format(_selectedDate ?? DateTime.now())}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = FirebaseAuth.instance.currentUser;
                    final plant = Plant(
                      id: widget.existingPlant?.id ?? '',
                      name: _nameController.text.trim(),
                      temperaturaMin: int.tryParse(_tempMinController.text),
                      temperaturaMax: int.tryParse(_tempMaxController.text),
                      umidadeMin: int.tryParse(_umidMinController.text),
                      umidadeMax: int.tryParse(_umidMaxController.text),
                      exposicaoSolar: _selectedLight,
                      dataPlantio: _selectedDate,
                      status: 'verde',
                      userId: user?.uid,
                    );

                    if (isEditing) {
                      await _service.updatePlant(plant);
                    } else {
                      await _service.createPlant(plant);
                    }

                    if (context.mounted) Navigator.of(context).pop();
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
