import 'package:flutter/material.dart';
import '../models/store_product.dart';

class StoreProductDetailPage extends StatelessWidget {
  final StoreProduct product;
  const StoreProductDetailPage({super.key, required this.product});

  Color get _green => const Color(0xFF2E7D32);

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = product.createdAt;
    final hasCategory = (product.category ?? '').isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        centerTitle: false,
        // garante ícone e título em branco
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        title: Text(product.cientificName, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child:
                  product.imageURL.isNotEmpty
                      ? Image.network(
                        product.imageURL,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(Icons.inventory_2, size: 48),
                            ),
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.inventory_2, size: 48),
                      ),
            ),
          ),
          const SizedBox(height: 12),

          // Card com informações
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + chips
                  Text(
                    product.cientificName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (hasCategory)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            product.category!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        'R\$ ${product.precoUnt.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  if (product.stock != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Estoque: ${product.stock}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),

                  // Especificações
                  const SizedBox(height: 8),
                  const Text(
                    'Especificações',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _SpecRow(
                    label: 'Validade (dias)',
                    value: product.valDias?.toString(),
                  ),
                  _SpecRow(
                    label: 'Faixa de Temperatura',
                    value: product.fxTemp,
                  ),
                  _SpecRow(label: 'Faixa de Umidade', value: product.fxUmidade),
                  _SpecRow(label: 'Tempo de Sol', value: product.tempoSol),
                  if (product.dataPlantio != null)
                    _SpecRow(
                      label: 'Data de Plantio',
                      value:
                          '${product.dataPlantio!.day.toString().padLeft(2, '0')}/${product.dataPlantio!.month.toString().padLeft(2, '0')}/${product.dataPlantio!.year}',
                    ),

                  // Descrições
                  if (product.descricaoPlanta.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Descrição da Planta',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(product.descricaoPlanta),
                  ],
                  if (product.descricaoProd.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Descrição do Produto',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(product.descricaoProd),
                  ],

                  if (createdAt != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Cadastrado em: ${_fmtDate(createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String? value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }
}
