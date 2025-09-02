import 'package:flutter/material.dart';
import '../models/plant.dart';
import 'leaf_glyph.dart';

class PlantCardWidget extends StatelessWidget {
  final Plant plant;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onOpen;

  const PlantCardWidget({
    super.key,
    required this.plant,
    required this.onDelete,
    required this.onEdit,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Dismissible(
        key: ValueKey(plant.id),
        direction: DismissDirection.horizontal,
        // Direita (startToEnd): Editar
        background: _swipeBg(
          align: Alignment.centerLeft,
          icon: Icons.edit,
          color: cs.primary.withValues(alpha: 0.1),
          iconColor: cs.primary,
          text: 'Editar',
        ),
        // Esquerda (endToStart): Apagar
        secondaryBackground: _swipeBg(
          align: Alignment.centerRight,
          icon: Icons.delete,
          color: cs.error.withValues(alpha: 0.1),
          iconColor: cs.error,
          text: 'Apagar',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // swipe para a direita -> editar
            onEdit();
          } else if (direction == DismissDirection.endToStart) {
            // swipe para a esquerda -> apagar
            onDelete();
          }
          return false;
        },
        child: InkWell(
          onTap: onOpen,
          onLongPress: onDelete,
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 88),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagem à esquerda (~30%)
                    Flexible(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildImage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Conteúdo
                    Expanded(
                      flex: 7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Métricas sem overflow
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _metric(cs, Icons.thermostat,
                                  '${plant.temperaturaMin ?? '-'}°C – ${plant.temperaturaMax ?? '-'}°C'),
                              _metric(cs, Icons.opacity,
                                  '${plant.umidadeMin ?? '-'}% – ${plant.umidadeMax ?? '-'}%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Folha à direita
                    LeafGlyph(
                      size: 28,
                      color: _colorFromStatus(plant.status),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = plant.imageURL;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _imagePlaceholder(isLoading: true),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder({bool isLoading = false}) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.image, color: Colors.grey, size: 24),
      ),
    );
  }
}

Color _colorFromStatus(String status) {
  switch (status) {
    case 'verde':
      return Colors.green;
    case 'amarelo':
      return Colors.amber;
    case 'laranja':
      return Colors.orange;
    case 'vermelho':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

Widget _metric(ColorScheme cs, IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: cs.primary),
      const SizedBox(width: 4),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: cs.onSurface),
        ),
      ),
    ],
  );
}

Widget _swipeBg({
  required Alignment align,
  required IconData icon,
  required Color color,
  required Color iconColor,
  required String text,
}) {
  return Container(
    alignment: align,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    color: color,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: iconColor, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
