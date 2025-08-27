// lib/screens/address_selection_page.dart
import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../models/address.dart';
import 'address_form_page.dart';
import '../widgets/custom_button.dart';
import '../globals.dart';

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  String? selectedAddressId;

  Color get _green => const Color(0xFF2E7D32);

  Widget _addressSummary(Address a) {
    final line1 =
        StringBuffer()
          ..write(a.street)
          ..write(a.number.isNotEmpty ? ', ${a.number}' : '');
    final line2 =
        StringBuffer()
          ..write(a.neighborhood.isNotEmpty ? '${a.neighborhood} • ' : '')
          ..write(a.city)
          ..write(a.state.isNotEmpty ? '/${a.state}' : '');
    final line3 = 'CEP: ${a.cep}';
    final compl =
        a.complement.trim().isNotEmpty ? 'Complemento: ${a.complement}' : null;
    final ref =
        a.reference.trim().isNotEmpty ? 'Referência: ${a.reference}' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line1.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(line2.toString(), style: const TextStyle(fontSize: 13)),
        Text(line3, style: const TextStyle(fontSize: 13)),
        if (compl != null) Text(compl, style: const TextStyle(fontSize: 13)),
        if (ref != null) Text(ref, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _addButton(BuildContext context) {
    return CustomButton(
      label: 'Adicionar Novo Endereço',
      icon: Icons.add,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddressFormPage(address: null),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = getUserData()?.id ?? '';
    if (uid.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Selecionar Endereço de Entrega'),
          centerTitle: true,
          backgroundColor: _green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Sessão expirada. Faça login novamente.'),
        ),
      );
    }

    final addressService = AddressService(userId: uid);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Selecionar Endereço de Entrega'),
        centerTitle: true,
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Address>>(
        stream: addressService.getAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar endereços'));
          }

          final addresses = snapshot.data ?? [];

          // Sem endereços: botão centralizado + rodapé desabilitado
          if (addresses.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: _addButton(context),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SafeArea(
                    top: false,
                    child: CustomButton(
                      label: 'Confirmar Endereço',
                      icon: Icons.check_circle,
                      backgroundColor: _green,
                      textColor: Colors.white,
                      onPressed: null,
                    ),
                  ),
                ),
              ],
            );
          }

          // Com endereços: o botão faz parte da lista (último item)
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  // deixa espaço para o rodapé fixo
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  itemCount: addresses.length + 1, // +1 para o botão no fim
                  itemBuilder: (context, index) {
                    if (index < addresses.length) {
                      final address = addresses[index];

                      return Dismissible(
                        key: ValueKey(address.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Colors.red.shade400,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          final ok =
                              await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text('Excluir endereço'),
                                      content: const Text(
                                        'Deseja realmente excluir este endereço?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text('Excluir'),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                        ),
                                      ],
                                    ),
                              ) ??
                              false;
                          if (ok) {
                            await addressService.deleteAddress(address.id);
                          }
                          return false; // a stream atualiza a lista
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: const Color(0xFFF4F8F2),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddressFormPage(address: address),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Radio<String>(
                                    value: address.id,
                                    groupValue: selectedAddressId,
                                    onChanged:
                                        (v) => setState(
                                          () => selectedAddressId = v,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: _addressSummary(address)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // ÚLTIMO ITEM: botão "Adicionar Novo Endereço"
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: _addButton(context),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Rodapé fixo com "Confirmar"
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SafeArea(
                  top: false,
                  child: CustomButton(
                    label: 'Confirmar Endereço',
                    icon: Icons.check_circle,
                    backgroundColor: _green,
                    textColor: Colors.white,
                    onPressed:
                        selectedAddressId == null
                            ? null
                            : () {
                              final list = snapshot.data ?? [];
                              final sel = list.firstWhere(
                                (e) => e.id == selectedAddressId,
                              );
                              Navigator.pop(context, sel);
                            },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
