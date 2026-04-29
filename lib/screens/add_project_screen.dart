import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController(text: '300');
  int _prioridad = 2;
  bool _loading = false;

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
      await ApiService().postProyecto(
        _nombreCtrl.text.trim(),
        int.parse(_duracionCtrl.text),
        _prioridad,
      );
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
          title: const Text('Nuevo Proyecto', style: TextStyle(color: Colors.white))),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _field(_nombreCtrl, 'Nombre del proyecto', required: true),
          const SizedBox(height: 16),
          _field(_duracionCtrl, 'Duración total estimada (min)', keyboardType: TextInputType.number, required: true),
          const SizedBox(height: 16),
          Text('Prioridad: $_prioridad', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Slider(
            value: _prioridad.toDouble(), min: 1, max: 5, divisions: 4,
            label: '$_prioridad', activeColor: const Color(0xFF26A69A),
            onChanged: (v) => setState(() => _prioridad = v.toInt()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _loading ? null : _guardar,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Guardar y Generar Sesiones', style: TextStyle(fontSize: 15)),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, TextInputType? keyboardType}) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF26A69A))),
        ),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null : null,
      );
}
