class Activity {
  final int id;
  final String nombre;
  final int duracion;
  final int prioridad;
  final String deadline;
  final String categoria;
  final String estado;

  Activity({
    required this.id,
    required this.nombre,
    required this.duracion,
    required this.prioridad,
    required this.deadline,
    required this.categoria,
    required this.estado,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        duracion: json['duracion_estimada'] as int,
        prioridad: json['prioridad'] as int,
        deadline: json['deadline'] as String? ?? '',
        categoria: json['categoria'] as String,
        estado: json['estado'] as String,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'duracion_estimada': duracion,
        'prioridad': prioridad,
        'deadline': deadline,
        'categoria': categoria,
      };
}
