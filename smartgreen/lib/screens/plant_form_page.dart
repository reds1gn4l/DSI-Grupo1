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
  final _tempMinController = TextEditingController();
  final _tempMaxController = TextEditingController();
  final _umidadeMinController = TextEditingController();
  final _umidadeMaxController = TextEditingController();

  late DateTime _dataPlantio;

  @override
  void initState() {
    super.initState();

    // Preenche os campos se for edição
    if (widget.plant != null) {
      _nameController.text = widget.plant!.name;
      _tempMinController.text = widget.plant!.temperaturaMin?.toString() ?? '';
      _tempMaxController.text = widget.plant!.temperaturaMax?.toString() ?? '';
      _umidadeMinController.text = widget.plant!.umidadeMin?.toString() ?? '';
      _umidadeMaxController.text = widget.plant!.umidadeMax?.toString() ?? '';
      _dataPlantio = widget.plant!.dataPlantio ?? DateTime.now();
    } else {
      _dataPlantio = DateTime.now(); // pré-preenchida com a data do dia
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

  @override
  Widget build(BuildContext context) {
    final headerTitle =
        widget.plant == null ? 'Cadastrar Planta' : 'Editar Planta';

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          // Faixa verde com título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2E7D32),
            child: Text(
              headerTitle,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
                        labelText: 'Nome da planta',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome da planta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Temperatura min / max
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tempMinController,
                            decoration: const InputDecoration(
                              labelText: 'Temperatura Mín. (°C)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _tempMaxController,
                            decoration: const InputDecoration(
                              labelText: 'Temperatura Máx. (°C)',
                            ),
                            keyboardType: TextInputType.number,
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
                              labelText: 'Umidade Mín. (%)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _umidadeMaxController,
                            decoration: const InputDecoration(
                              labelText: 'Umidade Máx. (%)',
                            ),
                            keyboardType: TextInputType.number,
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
                    const SizedBox(height: 24),

                    // Botão salvar
                    ElevatedButton(
                      onPressed: _savePlant,
                      child: Text(
                        widget.plant == null ? 'Salvar' : 'Salvar alterações',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    final plant = Plant(
      id: widget.plant?.id ?? '',
      name: _nameController.text.trim(),
      temperaturaMin: int.tryParse(_tempMinController.text),
      temperaturaMax: int.tryParse(_tempMaxController.text),
      umidadeMin: int.tryParse(_umidadeMinController.text),
      umidadeMax: int.tryParse(_umidadeMaxController.text),
      dataPlantio: _dataPlantio, // ✅ volta a salvar a data
      status: widget.plant?.status ?? 'cinza', // exigido pelo construtor
      // se seu modelo tiver mais campos obrigatórios, inclua aqui
    );

    if (widget.plant == null) {
      await PlantService().addPlant(plant);
    } else {
      await PlantService().updatePlant(plant);
    }

    if (mounted) Navigator.pop(context);
  }
}
