// lib/screens/map_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../models/address.dart';
import '../widgets/custom_button.dart';

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

  // Campos
  final streetCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final neighborhoodCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cepCtrl = TextEditingController();
  final complementCtrl = TextEditingController();
  final referenceCtrl = TextEditingController();

  final mapController = MapController();

  // Variáveis para busca do CEP
  bool _isSearchingCep = false;
  Timer? _cepDebounceTimer;

  // --- UF helpers (aceita nome por extenso e sigla; devolve sempre SIGLA) ---
  static const Set<String> _ufs = {
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  };

  static const Map<String, String> _ufNameToCode = {
    'ACRE': 'AC',
    'ALAGOAS': 'AL',
    'AMAPÁ': 'AP',
    'AMAPA': 'AP',
    'AMAZONAS': 'AM',
    'BAHIA': 'BA',
    'CEARÁ': 'CE',
    'CEARA': 'CE',
    'DISTRITO FEDERAL': 'DF',
    'ESPÍRITO SANTO': 'ES',
    'ESPIRITO SANTO': 'ES',
    'GOIÁS': 'GO',
    'GOIAS': 'GO',
    'MARANHÃO': 'MA',
    'MARANHAO': 'MA',
    'MATO GROSSO': 'MT',
    'MATO GROSSO DO SUL': 'MS',
    'MINAS GERAIS': 'MG',
    'PARÁ': 'PA',
    'PARA': 'PA',
    'PARAÍBA': 'PB',
    'PARAIBA': 'PB',
    'PARANÁ': 'PR',
    'PARANA': 'PR',
    'PERNAMBUCO': 'PE',
    'PIAUÍ': 'PI',
    'PIAUI': 'PI',
    'RIO DE JANEIRO': 'RJ',
    'RIO GRANDE DO NORTE': 'RN',
    'RIO GRANDE DO SUL': 'RS',
    'RONDÔNIA': 'RO',
    'RONDONIA': 'RO',
    'RORAIMA': 'RR',
    'SANTA CATARINA': 'SC',
    'SÃO PAULO': 'SP',
    'SAO PAULO': 'SP',
    'SERGIPE': 'SE',
    'TOCANTINS': 'TO',
  };

  String _toUF(String input, {String fallback = ''}) {
    final up = input.trim().toUpperCase();
    if (up.isEmpty) return fallback;
    if (up.length == 2 && _ufs.contains(up)) return up;
    return _ufNameToCode[up] ?? fallback;
  }
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    streetCtrl.text = widget.address.street;
    numberCtrl.text = widget.address.number;
    neighborhoodCtrl.text = widget.address.neighborhood;
    cityCtrl.text = widget.address.city;
    stateCtrl.text = _toUF(
      widget.address.state,
      fallback: widget.address.state.toUpperCase(),
    );
    cepCtrl.text = widget.address.cep;
    complementCtrl.text = widget.address.complement;
    referenceCtrl.text = widget.address.reference;
    _loadInitialLocation();

    _setupCepListener();
  }

  @override
  void dispose() {
    _cepDebounceTimer?.cancel();
    streetCtrl.dispose();
    numberCtrl.dispose();
    neighborhoodCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    cepCtrl.dispose();
    complementCtrl.dispose();
    referenceCtrl.dispose();
    super.dispose();
  }

  String _bestCityFromPlacemarks(List<Placemark> ps) {
    // Evita confundir UF (sigla/nome) com cidade
    final ufSigla = _toUF(
      stateCtrl.text,
      fallback: stateCtrl.text.toUpperCase(),
    );
    final ufNome =
        _ufNameToCode.entries
            .firstWhere(
              (e) => e.value == ufSigla,
              orElse: () => const MapEntry('', ''),
            )
            .key;
    for (final p in ps) {
      final candidates = <String?>[
        p.locality,
        p.subAdministrativeArea,
        p.subLocality,
      ];
      for (final c in candidates) {
        final v = (c ?? '').trim();
        if (v.isEmpty) continue;
        final vUp = v.toUpperCase();
        if (vUp != ufSigla && vUp != ufNome) return v;
      }
    }
    return cityCtrl.text;
  }

  String _extractNumber(String? name) {
    if (name == null || name.trim().isEmpty) return numberCtrl.text;
    final m = RegExp(r'\b(\d+)\b').firstMatch(name);
    return m?.group(1) ?? numberCtrl.text;
  }

  Future<void> _loadInitialLocation() async {
    try {
      if (widget.address.lat != null && widget.address.lng != null) {
        _location = LatLng(widget.address.lat!, widget.address.lng!);
      } else {
        final query = [
          widget.address.street,
          widget.address.number,
          widget.address.neighborhood,
          widget.address.city,
          widget.address.state,
          widget.address.cep,
        ].where((e) => e.trim().isNotEmpty).join(', ');

        if (query.isNotEmpty) {
          final results = await locationFromAddress(query);
          if (results.isNotEmpty) {
            _location = LatLng(results.first.latitude, results.first.longitude);
          }
        }
      }
      if (_location == null) {
        _errorMessage = 'Endereço não encontrado';
      }
    } catch (e) {
      _errorMessage = 'Erro ao localizar: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseAndFill(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          streetCtrl.text = p.thoroughfare ?? p.street ?? streetCtrl.text;
          numberCtrl.text = p.subThoroughfare ?? _extractNumber(p.name);
          neighborhoodCtrl.text = p.subLocality ?? neighborhoodCtrl.text;
          cityCtrl.text = _bestCityFromPlacemarks(placemarks);
          final uf = _toUF(
            p.administrativeArea ?? '',
            fallback: stateCtrl.text.toUpperCase(),
          );
          stateCtrl.text = uf.isNotEmpty ? uf : stateCtrl.text;
          cepCtrl.text = p.postalCode ?? cepCtrl.text;
          _location = latLng;
        });
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
  }

  // ---------- Busca de CEP ----------
  void _setupCepListener() {
    cepCtrl.addListener(() {
      _cepDebounceTimer?.cancel();

      _cepDebounceTimer = Timer(const Duration(milliseconds: 800), () {
        final cep = cepCtrl.text.trim();
        final cleanCep = cep.replaceAll(RegExp(r'\D'), '');

        if (cleanCep.length == 8) {
          _fetchAddressFromCep(cep);
        }
      });
    });
  }

  Future<void> _fetchAddressFromCep(String cep) async {
    if (_isSearchingCep) return;

    setState(() {
      _isSearchingCep = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://viacep.com.br/ws/$cep/json/'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['erro'] != true) {
          // Preenche os campos com os dados da API
          setState(() {
            streetCtrl.text = data['logradouro'] ?? '';
            neighborhoodCtrl.text = data['bairro'] ?? '';
            cityCtrl.text = data['localidade'] ?? '';
            stateCtrl.text = data['uf'] ?? '';
            cepCtrl.text = data['cep'] ?? cepCtrl.text;
          });

          // Tenta geocodificar o endereço completo para obter coordenadas
          _geocodeAddressFromCep(data);
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar CEP: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingCep = false;
        });
      }
    }
  }

  Future<void> _geocodeAddressFromCep(Map<String, dynamic> data) async {
    try {
      final query = [
        data['logradouro'],
        data['bairro'],
        data['localidade'],
        data['uf'],
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      if (query.isNotEmpty) {
        final results = await locationFromAddress(query);
        if (results.isNotEmpty) {
          final newLocation = LatLng(
            results.first.latitude,
            results.first.longitude,
          );

          setState(() {
            _location = newLocation;
          });

          // Move o mapa para a nova localização
          mapController.move(newLocation, 16);
        }
      }
    } catch (e) {
      debugPrint('Erro no geocoding: $e');
    }
  }

  Widget _buildForm(BuildContext context) {
    // Inputs herdam InputDecorationTheme do tema global
    InputDecoration dec(String label) => InputDecoration(
      labelText: label,
      suffixIcon:
          label == 'CEP' && _isSearchingCep
              ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : null,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: cepCtrl,
                  decoration: dec('CEP'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: stateCtrl,
                  decoration: dec('UF'),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (v) {
                    final norm = _toUF(v, fallback: v.toUpperCase());
                    if (norm != stateCtrl.text) {
                      final sel = stateCtrl.selection;
                      stateCtrl.value = TextEditingValue(
                        text: norm,
                        selection: sel,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cityCtrl,
                  decoration: dec('Cidade'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: neighborhoodCtrl,
                  decoration: dec('Bairro'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: streetCtrl,
                  decoration: dec('Endereço'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: numberCtrl,
                  decoration: dec('Número'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: complementCtrl,
                  decoration: dec('Complemento'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: referenceCtrl,
                  decoration: dec('Referência'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_location == null) {
      return const Expanded(
        child: Center(child: Text('Sem localização para exibir.')),
      );
    }
    return Expanded(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: _location!,
          initialZoom: 16,
          onTap: (_, latLng) => _reverseAndFill(latLng),
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
                  Icons.location_on,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Localização'),
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                children: [
                  _buildForm(context),
                  const SizedBox(height: 12), // espaçamento padrão app
                  _buildMap(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'Usar este endereço',
                        icon: Icons.check,
                        backgroundColor: cs.primary,
                        textColor: cs.onPrimary,
                        onPressed: () {
                          final updated = Address(
                            id: widget.address.id,
                            cep: cepCtrl.text.trim(),
                            state: _toUF(
                              stateCtrl.text,
                              fallback: stateCtrl.text.toUpperCase(),
                            ),
                            city: cityCtrl.text.trim(),
                            neighborhood: neighborhoodCtrl.text.trim(),
                            street: streetCtrl.text.trim(),
                            number:
                                numberCtrl.text.trim().isEmpty
                                    ? 'SN'
                                    : numberCtrl.text.trim(),
                            complement: complementCtrl.text.trim(),
                            reference: referenceCtrl.text.trim(),
                            lat: _location?.latitude,
                            lng: _location?.longitude,
                          );
                          Navigator.pop(context, updated);
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
