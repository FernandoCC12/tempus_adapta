class Project {
  final int id;
  final String nombre;
  final int duracionTotal;
  final double progreso;
  final int prioridad;

  Project({
    required this.id,
    required this.nombre,
    required this.duracionTotal,
    required this.progreso,
    required this.prioridad,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        duracionTotal: json['duracion_total'] as int,
        progreso: (json['progreso'] as num).toDouble(),
        prioridad: json['prioridad'] as int,
      );
}
