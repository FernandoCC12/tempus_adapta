import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController(text: '60');
  int _prioridad = 3;
  String _categoria = 'trabajo';
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;

  static const _categorias = ['trabajo', 'estudio', 'personal', 'ocio'];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _duracionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService().postActividad({
        'nombre': _nombreCtrl.text.trim(),
        'duracion_estimada': int.parse(_duracionCtrl.text),
        'prioridad': _prioridad,
        'deadline': _deadline.toIso8601String().substring(0, 10),
        'categoria': _categoria,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
        context: context, initialDate: _deadline,
        firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Nueva Actividad', style: TextStyle(color: Colors.white))),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _field(_nombreCtrl, 'Nombre', required: true),
          const SizedBox(height: 16),
          _field(_duracionCtrl, 'Duración (minutos)', keyboardType: TextInputType.number, required: true),
          const SizedBox(height: 16),
          _label('Prioridad (1=alta, 5=baja)'),
          Slider(
            value: _prioridad.toDouble(), min: 1, max: 5, divisions: 4,
            label: '$_prioridad', activeColor: const Color(0xFF5C6BC0),
            onChanged: (v) => setState(() => _prioridad = v.toInt()),
          ),
          const SizedBox(height: 8),
          _label('Categoría'),
          DropdownButtonFormField<String>(
            initialValue: _categoria,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(''),
            items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _categoria = v!),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: _label('Deadline: ${_deadline.toIso8601String().substring(0, 10)}'),
            trailing: IconButton(
                icon: const Icon(Icons.calendar_today, color: Color(0xFF5C6BC0)),
                onPressed: _pickDeadline),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _loading ? null : _guardar,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Guardar', style: TextStyle(fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13));

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, TextInputType? keyboardType}) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null : null,
      );

  InputDecoration _inputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C6BC0))));
}
