// Correções:
// 1. Importar o pacote 'url_launcher' para usar canLaunchUrl e launchUrl
// 2. Substituir 'AttributionWidget.defaultWidget' por 'RichAttributionWidget'

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- IMPORTANTE
import '../models/address.dart';

class MapPage extends StatefulWidget {
  final Address address;

  const MapPage({super.key, required this.address});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _location;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final fullAddress =
          '${widget.address.street}, ${widget.address.city}, ${widget.address.cep}';
      final results = await locationFromAddress(fullAddress);

      if (results.isEmpty) {
        setState(() {
          _errorMessage = 'Endereço não encontrado';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _location = LatLng(results.first.latitude, results.first.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar localização: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _location!,
        initialZoom: 15.0,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.smartgreen',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _location!,
              width: 60,
              height: 60,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 50,
              ),
            ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () async {
                final url = Uri.parse('https://openstreetmap.org/copyright');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização no Mapa'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                        onPressed: _loadLocation,
                      ),
                    ],
                  ),
                ),
              )
              : _buildMap(),
      floatingActionButton:
          _location != null
              ? FloatingActionButton(
                onPressed: () {
                  // Ação para usar esta localização
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.check),
              )
              : null,
    );
  }
}
