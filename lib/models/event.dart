class Event {
  final int id;
  final String nombre;
  final String inicio;
  final String fin;
  final String tipo; // 'fijo' | 'ocasional'

  Event({
    required this.id,
    required this.nombre,
    required this.inicio,
    required this.fin,
    required this.tipo,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        inicio: json['inicio'] as String,
        fin: json['fin'] as String,
        tipo: json['tipo'] as String? ?? 'fijo',
      );
}
