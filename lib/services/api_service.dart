import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/planning_item.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<PlanningItem>> getPlanificacion(String fecha) async {
    final res = await http.get(Uri.parse('$baseUrl/planificacion?fecha=$fecha'));
    if (res.statusCode != 200) throw Exception('Error al cargar planificación');
    final List data = json.decode(res.body);
    return data.map((e) => PlanningItem.fromJson(e)).toList();
  }

  Future<void> postActividad(Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl/actividad'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(body));
    if (res.statusCode != 200) throw Exception('Error al crear actividad');
  }

  Future<void> postCompletar(int id, int duracionReal, int energia) async {
    final res = await http.post(Uri.parse('$baseUrl/completar/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'duracion_real': duracionReal, 'energia': energia}));
    if (res.statusCode != 200) throw Exception('Error al completar');
  }

  Future<void> postEstado(int energia) async {
    final res = await http.post(Uri.parse('$baseUrl/estado'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'energia': energia}));
    if (res.statusCode != 200) throw Exception('Error al guardar estado');
  }

  Future<Map<String, dynamic>> getSugerencia(
      int duracion, String categoria, int energia, int diaSemana, String franjas) async {
    final uri = Uri.parse(
        '$baseUrl/sugerencia?duracion=$duracion&categoria=$categoria&energia=$energia&dia_semana=$diaSemana&franjas=$franjas');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Error sugerencia');
    return json.decode(res.body);
  }

  Future<void> postReubicar(int actividadId, int nuevaHora, String nuevoDiaIso) async {
    final res = await http.post(Uri.parse('$baseUrl/reubicar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'actividad_id': actividadId, 'nueva_hora': nuevaHora, 'nuevo_dia_iso': nuevoDiaIso}));
    if (res.statusCode != 200) throw Exception('Error al reubicar');
  }

  Future<void> postProyecto(String nombre, int duracionTotal, int prioridad) async {
    final res = await http.post(Uri.parse('$baseUrl/proyecto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nombre': nombre, 'duracion_total': duracionTotal, 'prioridad': prioridad}));
    if (res.statusCode != 200) throw Exception('Error al crear proyecto');
  }

  Future<List<Map<String, dynamic>>> getProyectos() async {
    final res = await http.get(Uri.parse('$baseUrl/proyectos'));
    if (res.statusCode != 200) throw Exception('Error al obtener proyectos');
    final List data = json.decode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> postEventoFijo(String nombre, String inicio, String fin, String recurrencia) async {
    final res = await http.post(Uri.parse('$baseUrl/evento_fijo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nombre': nombre, 'inicio': inicio, 'fin': fin, 'recurrencia': recurrencia}));
    if (res.statusCode != 200) throw Exception('Error al crear evento fijo');
  }

  Future<void> postEventoOcasional(String nombre, String inicio, String fin) async {
    final res = await http.post(Uri.parse('$baseUrl/evento_ocasional'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nombre': nombre, 'inicio': inicio, 'fin': fin}));
    if (res.statusCode != 200) throw Exception('Error al crear evento ocasional');
  }

  Future<void> postRecordatorio(String nombre, String fechaHora) async {
    final res = await http.post(Uri.parse('$baseUrl/recordatorio'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nombre': nombre, 'fecha_hora': fechaHora}));
    if (res.statusCode != 200) throw Exception('Error al crear recordatorio');
  }

  Future<List<Map<String, dynamic>>> getRecordatorios() async {
    final res = await http.get(Uri.parse('$baseUrl/recordatorios'));
    if (res.statusCode != 200) throw Exception('Error al obtener recordatorios');
    final List data = json.decode(res.body);
    return data.cast<Map<String, dynamic>>();
  }
}
