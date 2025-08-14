import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import 'plant_form_page.dart';
import '../services/plant_service.dart';

class PlantDetailPage extends StatefulWidget {
  final String plantId;

  const PlantDetailPage({super.key, required this.plantId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  Plant? plant;

  @override
  void initState() {
    super.initState();
    fetchPlant();
  }

  Future<void> fetchPlant() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('plants')
            .doc(widget.plantId)
            .get();

    if (doc.exists) {
      setState(() {
        plant = Plant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (plant == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final plantingText =
        plant!.dataPlantio != null
            ? DateFormat('dd/MM/yyyy').format(plant!.dataPlantio!)
            : 'Não informada';

    return Scaffold(
      appBar: AppBar(
        title: Text(plant!.name.isNotEmpty ? plant!.name : 'Planta sem nome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlantFormPage(plant: plant!)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeletion(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFF2E7D32),
            child: const Center(
              child: Text(
                'Detalhes da Planta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Data de plantio:', plantingText),
                  const SizedBox(height: 16),
                  _statusBar(
                    label: 'Temperatura',
                    min: -10,
                    max: 75,
                    value: plant!.mediaTemperatura ?? 0,
                    idealMin: plant!.temperaturaMin,
                    idealMax: plant!.temperaturaMax,
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.red,
                      ],
                    ),
                    unit: '°C',
                    icon: const Icon(
                      Icons.thermostat,
                      size: 49,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _statusBar(
                    label: 'Umidade',
                    min: 0,
                    max: 100,
                    value: plant!.mediaUmidade ?? 0,
                    idealMin: plant!.umidadeMin,
                    idealMax: plant!.umidadeMax,
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blueAccent,
                        Colors.blue,
                        Colors.indigo,
                      ],
                    ),
                    unit: '%',
                    icon: const Icon(
                      Icons.water_drop,
                      size: 49,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _statusBar(
                    label: 'Luz Solar (últimas 24h)',
                    min: 0,
                    max: 16,
                    value: plant!.horasLuz ?? 0,
                    idealMin: _idealLuzMin(plant!.exposicaoSolar ?? ''),
                    idealMax: _idealLuzMax(plant!.exposicaoSolar ?? ''),
                    gradient: const LinearGradient(
                      colors: [Colors.black, Colors.orange, Colors.yellow],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    unit: 'h',
                    icon: const Icon(
                      Icons.wb_sunny,
                      size: 49,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }

  Widget _statusBar({
    required String label,
    required double min,
    required double max,
    required double value,
    required int? idealMin,
    required int? idealMax,
    required Gradient gradient,
    required String unit,
    required Icon icon,
  }) {
    const barHeight = 20.0;
    final clamped = value.clamp(min, max);
    final percent = (clamped - min) / (max - min);
    final iconSize = icon.size ?? 48.0;

    final topPaddingForIcon = iconSize * 0.55;
    final bottomPaddingForIcon = (iconSize - barHeight) / 2;
    final iconTop = topPaddingForIcon - (iconSize - barHeight) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${clamped.toStringAsFixed(1)}$unit'),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final iconLeft = (percent * barWidth - iconSize / 2).clamp(
              0.0,
              barWidth - iconSize,
            );

            return SizedBox(
              height: topPaddingForIcon + barHeight + bottomPaddingForIcon,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    top: topPaddingForIcon,
                    bottom: bottomPaddingForIcon,
                    child: Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(left: iconLeft, top: iconTop, child: icon),
                ],
              ),
            );
          },
        ),
        if (idealMin != null && idealMax != null) const SizedBox(height: 8),
        if (idealMin != null && idealMax != null)
          Text(
            'Ideal: $idealMin–$idealMax$unit',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  int _idealLuzMin(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'sol pleno':
        return 6;
      case 'parcial':
        return 3;
      case 'sombra':
        return 0;
      default:
        return 0;
    }
  }

  int _idealLuzMax(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'sol pleno':
        return 12;
      case 'parcial':
        return 6;
      case 'sombra':
        return 3;
      default:
        return 16;
    }
  }

  void _confirmDeletion(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Excluir planta'),
            content: const Text('Deseja realmente excluir esta planta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await PlantService().deletePlant(plant!.id);
      // CORREÇÃO APLICADA AQUI
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
