import 'package:flutter/material.dart';

/// Folha reutilizável para status/placeholder.
/// Use `color` para definir a cor (ex.: Colors.grey.shade400)
/// e `size` para o tamanho.
class LeafGlyph extends StatelessWidget {
  final double size;
  final Color color;

  const LeafGlyph({super.key, required this.size, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.eco, size: size, color: color);
  }
}
