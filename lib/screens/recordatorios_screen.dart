import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecordatoriosScreen extends StatefulWidget {
  const RecordatoriosScreen({super.key});

  @override
  State<RecordatoriosScreen> createState() => _RecordatoriosScreenState();
}

class _RecordatoriosScreenState extends State<RecordatoriosScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _recordatorios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _recordatorios = await _api.getRecordatorios();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showAddDialog() {
    final nombreCtrl = TextEditingController();
    DateTime fechaHora = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx2, setS) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Nuevo Recordatorio', style: TextStyle(color: Colors.white)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
            ),
            const SizedBox(height: 12),
            Text(fechaHora.toIso8601String().substring(0, 16),
                style: const TextStyle(color: Colors.white70)),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, color: Color(0xFF5C6BC0)),
              label: const Text('Seleccionar fecha/hora', style: TextStyle(color: Color(0xFF5C6BC0))),
              onPressed: () => _pickRecordatorioDate(ctx2, fechaHora, (dt) => setS(() => fechaHora = dt)),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx2),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C6BC0)),
              onPressed: () => _saveRecordatorio(ctx2, nombreCtrl.text.trim(), fechaHora),
              child: const Text('Guardar'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _pickRecordatorioDate(BuildContext ctx, DateTime current, void Function(DateTime) onPicked) async {
    final d = await showDatePicker(
        context: ctx, initialDate: current,
        firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d == null || !ctx.mounted) return;
    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
    if (t == null) return;
    onPicked(DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _saveRecordatorio(BuildContext ctx, String nombre, DateTime fechaHora) async {
    if (nombre.isEmpty) return;
    await _api.postRecordatorio(nombre, fechaHora.toIso8601String());
    if (ctx.mounted) Navigator.pop(ctx);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Recordatorios', style: TextStyle(color: Colors.white))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recordatorios.isEmpty
              ? const Center(child: Text('Sin recordatorios', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _recordatorios.length,
                  itemBuilder: (_, i) {
                    final r = _recordatorios[i];
                    return Card(
                      color: const Color(0xFF1E293B),
                      child: ListTile(
                        leading: const Icon(Icons.alarm, color: Color(0xFF5C6BC0)),
                        title: Text(r['nombre'] ?? '', style: const TextStyle(color: Colors.white)),
                        subtitle: Text(r['fecha_hora'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                    );
                  }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C6BC0),
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
