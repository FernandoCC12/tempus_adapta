import 'package:flutter/material.dart';

class ProjectProgressBar extends StatelessWidget {
  final Map<String, dynamic> proyecto;

  const ProjectProgressBar({super.key, required this.proyecto});

  @override
  Widget build(BuildContext context) {
    final progreso = (proyecto['progreso'] as num?)?.toDouble() ?? 0.0;
    final nombre = proyecto['nombre'] as String? ?? '';

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(nombre,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progreso.clamp(0.0, 1.0),
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
          ),
          const SizedBox(height: 4),
          Text('${(progreso * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}
