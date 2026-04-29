import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  bool _esFijo = true;
  String _recurrencia = 'NINGUNA';
  DateTime _inicio = DateTime.now();
  DateTime _fin = DateTime.now().add(const Duration(hours: 1));
  bool _loading = false;

  static const _recurrencias = ['NINGUNA', 'DIARIA', 'SEMANAL', 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES'];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  String _formatDt(DateTime dt) => '${dt.toIso8601String().substring(0, 10)}T${dt.hour.toString().padLeft(2, '0')}:00:00';

  Future<void> _pickDateTime(bool esInicio) async {
    final date = await showDatePicker(
        context: context,
        initialDate: esInicio ? _inicio : _fin,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour);
    setState(() => esInicio ? _inicio = dt : _fin = dt);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final api = ApiService();
    try {
      if (_esFijo) {
        await api.postEventoFijo(_nombreCtrl.text.trim(), _formatDt(_inicio), _formatDt(_fin), _recurrencia);
      } else {
        await api.postEventoOcasional(_nombreCtrl.text.trim(), _formatDt(_inicio), _formatDt(_fin));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Nuevo Evento', style: TextStyle(color: Colors.white))),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          TextFormField(
            controller: _nombreCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Nombre del evento',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
            validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(_esFijo ? 'Evento Fijo' : 'Evento Ocasional',
                style: const TextStyle(color: Colors.white)),
            value: _esFijo,
            activeThumbColor: const Color(0xFF5C6BC0),
            onChanged: (v) => setState(() => _esFijo = v),
          ),
          if (_esFijo) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _recurrencia,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Recurrencia',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
              items: _recurrencias.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _recurrencia = v!),
            ),
          ],
          const SizedBox(height: 16),
          _dateTimeTile('Inicio', _inicio, () => _pickDateTime(true)),
          _dateTimeTile('Fin', _fin, () => _pickDateTime(false)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _loading ? null : _guardar,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Guardar Evento', style: TextStyle(fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  Widget _dateTimeTile(String label, DateTime dt, VoidCallback onTap) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('$label: ${_formatDt(dt)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        trailing: IconButton(icon: const Icon(Icons.edit, color: Color(0xFF5C6BC0)), onPressed: onTap),
      );
}
