class Session {
  final int id;
  final int idProyecto;
  final int duracion;
  final bool completado;
  final String fechaAsignada;

  Session({
    required this.id,
    required this.idProyecto,
    required this.duracion,
    required this.completado,
    required this.fechaAsignada,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as int,
        idProyecto: json['id_proyecto'] as int,
        duracion: json['duracion'] as int,
        completado: (json['completado'] as int) == 1,
        fechaAsignada: json['fecha_asignada'] as String,
      );
}
