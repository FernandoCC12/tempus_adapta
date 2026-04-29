import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/planning_item.dart';
import '../services/api_service.dart';
import '../widgets/activity_block.dart';
import '../widgets/project_progress_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  DateTime _weekStart = _mondayOf(DateTime.now());
  List<PlanningItem> _plan = [];
  List<Map<String, dynamic>> _proyectos = [];
  bool _loading = false;

  static DateTime _mondayOf(DateTime d) =>
      d.subtract(Duration(days: d.weekday - 1));

  @override
  void initState() {
    super.initState();
    _loadPlan();
    _loadProyectos();
  }

  Future<void> _loadProyectos() async {
    try {
      _proyectos = await _api.getProyectos();
      setState(() {});
    } catch (_) {}
  }

  Future<void> _loadPlan() async {
    setState(() => _loading = true);
    try {
      final fecha = DateFormat('yyyy-MM-dd').format(_weekStart);
      _plan = await _api.getPlanificacion(fecha);
    } catch (_) {
      _showSnack('No se pudo conectar al servidor');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _setEnergia(int nivel) async {
    try {
      await _api.postEstado(nivel);
      _showSnack('Energía registrada');
    } catch (_) {
      _showSnack('Error al guardar energía');
    }
  }

  void _prevWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
    _loadPlan();
  }

  void _nextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
    _loadPlan();
  }

  PlanningItem? _itemAt(int dayIndex, int hour) {
    final dia = DateFormat('yyyy-MM-dd')
        .format(_weekStart.add(Duration(days: dayIndex)));
    try {
      return _plan.firstWhere((p) => p.diaIso == dia && p.horaInicio == hour);
    } catch (_) {
      return null;
    }
  }

  void _showItemDialog(PlanningItem item) {
    showDialog(context: context, builder: (_) => _ItemDialog(item: item, api: _api, onRefresh: _loadPlan));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              _buildEnergyRow(),
              if (_proyectos.isNotEmpty) _buildProjectsBar(),
              Expanded(child: _buildGrid()),
            ]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final label = '${DateFormat('dd MMM').format(_weekStart)} – '
        '${DateFormat('dd MMM yyyy').format(_weekStart.add(const Duration(days: 6)))}';
    return AppBar(
      backgroundColor: const Color(0xFF1E293B),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      leading: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: _prevWeek),
      actions: [IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: _nextWeek)],
    );
  }

  Widget _buildEnergyRow() {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _energyBtn('🔋 Baja', 0),
          _energyBtn('⚡ Normal', 1),
          _energyBtn('🚀 Alta', 2),
        ],
      ),
    );
  }

  Widget _buildProjectsBar() {
    return Container(
      color: const Color(0xFF0F172A),
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _proyectos.length,
        itemBuilder: (_, i) => ProjectProgressBar(proyecto: _proyectos[i]),
      ),
    );
  }

  Widget _energyBtn(String label, int nivel) => ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF334155),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        onPressed: () => _setEnergia(nivel),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      );

  Widget _buildGrid() {
    const hours = [8,9,10,11,12,13,14,15,16,17,18,19,20,21,22];
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(110),
          border: TableBorder.all(color: Colors.white12),
          children: [
            _headerRow(days),
            ...hours.map((h) => _hourRow(h, days.length)),
          ],
        ),
      ),
    );
  }

  TableRow _headerRow(List<String> days) => TableRow(
        decoration: const BoxDecoration(color: Color(0xFF1E293B)),
        children: [
          _cell(const Text('Hora', style: TextStyle(color: Colors.white54, fontSize: 11))),
          ...days.map((d) => _cell(Text(d,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
        ],
      );

  TableRow _hourRow(int hour, int numDays) => TableRow(children: [
        _cell(Text('$hour:00', style: const TextStyle(color: Colors.white54, fontSize: 11))),
        ...List.generate(numDays, (di) {
          final item = _itemAt(di, hour);
          if (item != null) {
            return ActivityBlock(
              nombre: item.nombre,
              duracion: item.duracion,
              categoria: _categoryFromTipo(item.tipo),
              onTap: () => _showItemDialog(item),
            );
          }
          return _cell(const SizedBox.shrink());
        }),
      ]);

  String _categoryFromTipo(String tipo) =>
      tipo == 'forzado' ? 'personal' : 'trabajo';

  Widget _cell(Widget child) => Padding(
        padding: const EdgeInsets.all(4),
        child: child,
      );
}

class _ItemDialog extends StatefulWidget {
  final PlanningItem item;
  final ApiService api;
  final VoidCallback onRefresh;

  const _ItemDialog({required this.item, required this.api, required this.onRefresh});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final TextEditingController _durCtrl = TextEditingController();

  @override
  void dispose() {
    _durCtrl.dispose();
    super.dispose();
  }

  Future<void> _completar() async {
    final dur = int.tryParse(_durCtrl.text) ?? widget.item.duracion;
    await widget.api.postCompletar(widget.item.actividadId!, dur, 1);
    if (mounted) Navigator.pop(context);
    widget.onRefresh();
  }

  Future<void> _reubicar(int nuevaHora) async {
    await widget.api.postReubicar(widget.item.actividadId!, nuevaHora, widget.item.diaIso);
    if (mounted) Navigator.pop(context);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: Text(widget.item.nombre,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _durCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Duración real (min)',
            labelStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
        TextButton(
            onPressed: () => _reubicar(widget.item.horaInicio + 1),
            child: const Text('Posponer +1h', style: TextStyle(color: Colors.amber))),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
            onPressed: _completar,
            child: const Text('Completar')),
      ],
    );
  }
}
