class PlanningItem {
  final int? actividadId;
  final String nombre;
  final String diaIso;
  final int horaInicio;
  final int duracion;
  final String tipo;

  PlanningItem({
    this.actividadId,
    required this.nombre,
    required this.diaIso,
    required this.horaInicio,
    required this.duracion,
    required this.tipo,
  });

  factory PlanningItem.fromJson(Map<String, dynamic> json) => PlanningItem(
        actividadId: json['actividad_id'] as int?,
        nombre: json['nombre'] as String,
        diaIso: json['dia_iso'] as String,
        horaInicio: json['hora_inicio'] as int,
        duracion: json['duracion'] as int,
        tipo: json['tipo'] as String,
      );
}
