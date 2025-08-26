import 'package:flutter/material.dart';
import '../models/store_product.dart';
import '../services/store_product_service.dart';
import 'store_product_form_page.dart';

class StoreProductDetailPage extends StatefulWidget {
  final String storeProductId;
  const StoreProductDetailPage({super.key, required this.storeProductId});

  @override
  State<StoreProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<StoreProductDetailPage> {
  final _service = StoreProductService();
  StoreProduct? _product;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _service.getById(widget.storeProductId);
    if (mounted) {
      setState(() => _product = p);
    }
  }

  Future<void> _delete() async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Remover produto'),
                content: const Text(
                  'Tem certeza que deseja remover este produto?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Remover'),
                  ),
                ],
              ),
        ) ??
        false;
    if (!ok) return;
    await _service.delete(widget.storeProductId);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(p.cientificName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreProductFormPage(storeProduct: p),
                ),
              );
              if (mounted) _load();
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if ((p.imageURL).isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                p.imageURL,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            p.cientificName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if ((p.category ?? '').isNotEmpty)
            Text(
              'Categoria: ${p.category}',
              style: const TextStyle(color: Colors.black87),
            ),
          Text(
            'Preço: R\$ ${p.precoUnt.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.black87),
          ),
          if (p.stock != null)
            Text(
              'Estoque: ${p.stock}',
              style: const TextStyle(color: Colors.black87),
            ),
          if (p.valDias != null)
            Text(
              'Validade (dias): ${p.valDias}',
              style: const TextStyle(color: Colors.black87),
            ),
          if (p.dataPlantio != null)
            Text(
              'Data de Plantio: '
              '${p.dataPlantio!.day.toString().padLeft(2, '0')}-'
              '${p.dataPlantio!.month.toString().padLeft(2, '0')}-'
              '${p.dataPlantio!.year}',
              style: const TextStyle(color: Colors.black87),
            ),
          if (p.fxTemp.isNotEmpty)
            Text(
              'Faixa de Temperatura: ${p.fxTemp}',
              style: const TextStyle(color: Colors.black87),
            ),
          if (p.fxUmidade.isNotEmpty)
            Text(
              'Faixa de Umidade: ${p.fxUmidade}',
              style: const TextStyle(color: Colors.black87),
            ),
          if (p.tempoSol.isNotEmpty)
            Text(
              'Tempo de Sol: ${p.tempoSol}',
              style: const TextStyle(color: Colors.black87),
            ),
          const SizedBox(height: 12),
          if ((p.descricaoPlanta).isNotEmpty)
            Text(
              'Descrição da Planta: ${p.descricaoPlanta}',
              style: const TextStyle(color: Colors.black87),
            ),
          if ((p.descricaoProd).isNotEmpty)
            Text(
              'Descrição do Produto: ${p.descricaoProd}',
              style: const TextStyle(color: Colors.black87),
            ),
          const SizedBox(height: 16),
          if (p.createdAt != null)
            Text(
              'Cadastrado em: ${p.createdAt}',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
