import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
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

  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final cepController = TextEditingController();

  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    streetController.text = widget.address.street;
    cityController.text = widget.address.city;
    cepController.text = widget.address.cep;
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    final fullAddress =
        '${widget.address.street}, ${widget.address.city}, ${widget.address.cep}';

    try {
      final results = await locationFromAddress(fullAddress);
      if (results.isNotEmpty) {
        setState(() {
          _location = LatLng(results.first.latitude, results.first.longitude);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Endereço não encontrado';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao localizar: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAddressFromCoordinates(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          streetController.text = place.street ?? '';
          cityController.text = place.locality ?? '';
          cepController.text = place.postalCode ?? '';
          _location = latLng;
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar endereço por coordenada: $e');
    }
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: streetController,
            decoration: const InputDecoration(
              labelText: 'Rua',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(
              labelText: 'Cidade',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cepController,
            decoration: const InputDecoration(
              labelText: 'CEP',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: _location!,
          initialZoom: 15.0,
          onTap: (tapPosition, latLng) {
            _updateAddressFromCoordinates(latLng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.smartgreen',
            maxZoom: 19,
          ),
          if (_location != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _location!,
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final newCenter = mapController.camera.center;
                      _updateAddressFromCoordinates(newCenter);
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Localização'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                children: [
                  _buildFormFields(),
                  _buildMap(),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Usar este endereço'),
                      onPressed: () {
                        final updatedAddress = Address(
                          id: widget.address.id,
                          street: streetController.text,
                          city: cityController.text,
                          cep: cepController.text,
                          complement: widget.address.complement,
                        );
                        Navigator.pop(context, updatedAddress);
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
