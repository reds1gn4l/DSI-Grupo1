// lib/screens/store_product_detail_page.dart
import 'package:flutter/material.dart';
import '../models/store_product.dart';

class StoreProductDetailPage extends StatelessWidget {
  final StoreProduct product;
  const StoreProductDetailPage({super.key, required this.product});

  String _money(num v) =>
      'R\$ ${v.toStringAsFixed(2)}'.replaceFirst(' ', '\u00A0'); // NBSP

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final createdAt = product.createdAt;
    final hasCategory = (product.category ?? '').isNotEmpty;

    return Scaffold(
      // usa scaffoldBackgroundColor do tema
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
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
                              color: cs.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: const Icon(Icons.inventory_2, size: 48),
                            ),
                      )
                      : Container(
                        color: cs.surfaceContainerHighest,
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
                  // Título + chips + preço
                  Text(
                    product.cientificName,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(product.category!, style: tt.labelSmall),
                        ),
                      const Spacer(),
                      Text(
                        _money(product.precoUnt),
                        style: tt.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  if (product.stock != null) ...[
                    const SizedBox(height: 6),
                    Text('Estoque: ${product.stock}', style: tt.bodySmall),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),

                  // Especificações
                  const SizedBox(height: 8),
                  Text(
                    'Especificações',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
                          '${product.dataPlantio!.day.toString().padLeft(2, '0')}/'
                          '${product.dataPlantio!.month.toString().padLeft(2, '0')}/'
                          '${product.dataPlantio!.year}',
                    ),

                  // Descrições
                  if (product.descricaoPlanta.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Descrição da Planta',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(product.descricaoPlanta, style: tt.bodyMedium),
                  ],
                  if (product.descricaoProd.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Descrição do Produto',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(product.descricaoProd, style: tt.bodyMedium),
                  ],

                  if (createdAt != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Cadastrado em: ${_fmtDate(createdAt)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
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
    final tt = Theme.of(context).textTheme;
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(label, style: tt.bodyMedium)),
          const SizedBox(width: 8),
          Expanded(child: Text(value!, style: tt.bodyMedium)),
        ],
      ),
    );
  }
}
