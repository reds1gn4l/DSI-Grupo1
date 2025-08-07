import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';

class PlantFormPage extends StatefulWidget {
  final Plant? plant;

  const PlantFormPage({super.key, this.plant});

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _temperaturaMinController = TextEditingController();
  final _temperaturaMaxController = TextEditingController();
  final _umidadeMinController = TextEditingController();
  final _umidadeMaxController = TextEditingController();
  final _plantingDateController = TextEditingController();

  String? _selectedLight = 'sol';
  final _service = PlantService();

  @override
  void initState() {
    super.initState();

    if (widget.plant != null) {
      final p = widget.plant!;
      _nameController.text = p.name;
      _temperaturaMinController.text = p.temperaturaMin?.toString() ?? '';
      _temperaturaMaxController.text = p.temperaturaMax?.toString() ?? '';
      _umidadeMinController.text = p.umidadeMin?.toString() ?? '';
      _umidadeMaxController.text = p.umidadeMax?.toString() ?? '';
      _plantingDateController.text = p.plantingDate ?? '';
      _selectedLight = p.lightPreference ?? 'sol';
    } else {
      _plantingDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.now());
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Coleta os valores
    final temperaturaMin = int.tryParse(_temperaturaMinController.text);
    final temperaturaMax = int.tryParse(_temperaturaMaxController.text);
    final umidadeMin = int.tryParse(_umidadeMinController.text);
    final umidadeMax = int.tryParse(_umidadeMaxController.text);

    // Lógica para determinar o status
    int erros = 0;
    if (temperaturaMin == null || temperaturaMin < 10 || temperaturaMin > 40)
      erros++;
    if (temperaturaMax == null || temperaturaMax < 10 || temperaturaMax > 40)
      erros++;
    if (umidadeMin == null || umidadeMin < 20 || umidadeMin > 90) erros++;
    if (umidadeMax == null || umidadeMax < 20 || umidadeMax > 90) erros++;

    String status;
    if (erros >= 3) {
      status = 'vermelho';
    } else if (erros == 2) {
      status = 'laranja';
    } else if (erros == 1) {
      status = 'amarelo';
    } else {
      status = 'verde';
    }

    final newPlant = Plant(
      id: widget.plant?.id ?? '',
      name: _nameController.text.trim(),
      status: status,
      temperaturaMin: temperaturaMin,
      temperaturaMax: temperaturaMax,
      umidadeMin: umidadeMin,
      umidadeMax: umidadeMax,
      plantingDate: _plantingDateController.text.trim(),
      lightPreference: _selectedLight,
    );

    if (widget.plant == null) {
      await _service.addPlant(newPlant);
    } else {
      await _service.updatePlant(newPlant);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plant != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar planta' : 'Nova planta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da planta'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Informe o nome'
                            : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _temperaturaMinController,
                      decoration: const InputDecoration(
                        labelText: 'Temp. mínima',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _temperaturaMaxController,
                      decoration: const InputDecoration(
                        labelText: 'Temp. máxima',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _umidadeMinController,
                      decoration: const InputDecoration(
                        labelText: 'Umidade mínima',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _umidadeMaxController,
                      decoration: const InputDecoration(
                        labelText: 'Umidade máxima',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _plantingDateController,
                decoration: const InputDecoration(labelText: 'Data de plantio'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLight,
                decoration: const InputDecoration(labelText: 'Exposição solar'),
                items: const [
                  DropdownMenuItem(value: 'sol', child: Text('Sempre ao sol')),
                  DropdownMenuItem(
                    value: 'sombra',
                    child: Text('Sempre à sombra'),
                  ),
                  DropdownMenuItem(
                    value: 'parcial',
                    child: Text('Parcialmente exposta'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedLight = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? 'Salvar' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
