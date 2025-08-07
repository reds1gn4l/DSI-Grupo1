import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../screens/plant_form_page.dart';
import '../services/plant_service.dart';

class PlantCardWidget extends StatelessWidget {
  final Plant plant;

  const PlantCardWidget({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStatusIcon(plant.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.thermostat, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatRange(
                          plant.temperaturaMin,
                          plant.temperaturaMax,
                          '°C',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                        ), // ✅ Fonte aumentada
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.water_drop, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatRange(plant.umidadeMin, plant.umidadeMax, '%'),
                        style: const TextStyle(
                          fontSize: 16,
                        ), // ✅ Fonte aumentada
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.teal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantFormPage(plant: plant),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeletion(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    Color color;
    switch (status) {
      case 'verde':
        color = Colors.green;
        break;
      case 'amarelo':
        color = Colors.yellow;
        break;
      case 'laranja':
        color = Colors.orange;
        break;
      case 'vermelho':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Icon(Icons.eco, size: 32, color: color);
  }

  String _formatRange(int? min, int? max, String unit) {
    if (min == null && max == null) return 'Indisponível';
    if (min != null && max == null) return '$min$unit';
    if (min == null && max != null) return '$max$unit';
    return '$min–$max$unit';
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
      await PlantService().deletePlant(plant.id);
    }
  }
}
