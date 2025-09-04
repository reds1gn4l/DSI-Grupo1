import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/user_photo_service.dart';
import '../widgets/custom_button.dart';
import 'plant_form_page.dart';

class PlantDetailPage extends StatefulWidget {
  final String plantId;

  const PlantDetailPage({super.key, required this.plantId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final PlantService _service = PlantService();
  Plant? _plant;
  String? _localPhotoPath;
  final _photoService = UserPhotoService();

  @override
  void initState() {
    super.initState();
    _loadPlant();
  }

  Future<void> _loadPlant() async {
    try {
      final plant = await _service.fetchPlantById(widget.plantId);
      if (!mounted) return;
      final localPath = await _photoService.getPhotoPath(widget.plantId);
      if (!mounted) return;
      setState(() {
        _plant = plant;
        _localPhotoPath = localPath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar planta: $e')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = _plant;
    if (plant == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            tooltip: 'Tirar foto',
            icon: const Icon(Icons.camera_alt),
            onPressed: _onTakePhoto,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopImage(),
            const SizedBox(height: 20),
            _buildSliderRow(
              title: 'Temperatura',
              value: plant.mediaTemperatura?.toDouble() ?? 0.0,
              min: -10,
              max: 75,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
              ),
              unit: '°C',
              icon: Icons.thermostat,
              iconColor: Colors.redAccent,
            ),
            _buildSliderRow(
              title: 'Umidade',
              value: plant.mediaUmidade?.toDouble() ?? 0.0,
              min: 0,
              max: 100,
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.blue, Colors.blueAccent],
              ),
              unit: '%',
              icon: Icons.opacity,
              iconColor: Colors.blueAccent,
            ),
            _buildSliderRow(
              title: 'Sol',
              value: plant.horasLuz?.toDouble() ?? 0.0,
              min: 0,
              max: 12,
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.yellow],
              ),
              unit: 'h',
              icon: Icons.wb_sunny,
              iconColor: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              'Plantada em: ${plant.dataPlantio != null ? DateFormat('dd/MM/yyyy').format(plant.dataPlantio!.toLocal()) : '---'}',
            ),
            Text('Exposição solar: ${plant.exposicaoSolar ?? '---'}'),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: CustomButton(
          label: 'Editar planta',
          icon: Icons.edit,
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlantFormPage(existingPlant: plant),
              ),
            );
            if (mounted) _loadPlant();
          },
        ),
      ),
    );
  }

  Widget _buildSliderRow({ 
    required String title,
    required double value,
    required double min,
    required double max,
    required LinearGradient gradient,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) { 
    final clamped = value.clamp(min, max); 
    final t = (clamped - min) / (max - min == 0 ? 1 : (max - min)); 
    const trackHeight = 12.0; 
    const markerSize = 24.0; 
    const innerIconSize = 16.0; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${clamped.toStringAsFixed(1)} $unit'),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth; 
            final left = (w - markerSize) * t; 
            final top = (24 - markerSize) / 2; 
            return SizedBox( 
              height: 24, 
              child: Stack( 
                children: [ 
                  Positioned.fill( 
                    top: (24 - trackHeight) / 2,
                    bottom: (24 - trackHeight) / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Positioned( 
                    left: left, 
                    top: top, 
                    child: Builder(
                      builder: (context) {
                        final cs = Theme.of(context).colorScheme;
                        return Container(
                          width: markerSize,
                          height: markerSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: cs.primary, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Icon(icon, size: innerIconSize, color: iconColor),
                        );
                      },
                    ),
                  ), 
                ], 
              ), 
            ); 
          }, 
        ), 
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildTopImage() {
    final url = _plant?.imageURL;
    const double height = 180;
    if (_localPhotoPath != null && _localPhotoPath!.isNotEmpty && File(_localPhotoPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_localPhotoPath!),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => _imagePlaceholder(height: height),
        ),
      );
    }
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          // Mostra nosso placeholder apenas em erro; no carregamento inicial deixa em branco
          errorBuilder: (_, __, ___) => _imagePlaceholder(height: height),
        ),
      );
    }
    return _imagePlaceholder(height: height);
  }

  Widget _imagePlaceholder({double height = 180, bool isLoading = false}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, size: 60, color: Colors.grey),
                const SizedBox(height: 8),
                const Text(
                  'Imagem indisponível',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

extension on BuildContext {
  void showSnack(String msg) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(msg)));
  }
}

extension _PickSave on _PlantDetailPageState {
  Future<void> _onTakePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, maxWidth: 2048, imageQuality: 85);
      if (image == null) return; // user canceled
      final savedPath = await _photoService.savePhotoForPlant(widget.plantId, File(image.path));
      if (!mounted) return;
      setState(() => _localPhotoPath = savedPath);
      if (!mounted) return;
      context.showSnack('Foto salva para esta planta.');
    } catch (e) {
      if (!mounted) return;
      context.showSnack('Falha ao salvar foto: $e');
    }
  }
}
