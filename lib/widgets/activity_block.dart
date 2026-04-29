import 'package:flutter/material.dart';

const Map<String, Color> _categoryColors = {
  'trabajo': Color(0xFF5C6BC0),
  'estudio': Color(0xFF26A69A),
  'personal': Color(0xFFEF5350),
  'ocio': Color(0xFFFFCA28),
};

Color colorForCategory(String categoria) =>
    _categoryColors[categoria.toLowerCase()] ?? const Color(0xFF78909C);

class ActivityBlock extends StatelessWidget {
  final String nombre;
  final int duracion;
  final String categoria;
  final VoidCallback onTap;

  const ActivityBlock({
    super.key,
    required this.nombre,
    required this.duracion,
    required this.categoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorForCategory(categoria);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nombre,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            Text('$duracion min',
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
