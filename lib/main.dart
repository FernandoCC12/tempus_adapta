import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_activity_screen.dart';
import 'screens/add_project_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/recordatorios_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const TempusAdaptaApp());
}

class TempusAdaptaApp extends StatelessWidget {
  const TempusAdaptaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempus Adapta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    RecordatoriosScreen(),
  ];

  void _navigateTo(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    // Refresh home after adding items
    if (_currentIndex == 0) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF5C6BC0),
        unselectedItemColor: Colors.white38,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Recordatorios'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? _buildFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _fabSmall(Icons.event, const Color(0xFF26A69A), () => _navigateTo(const AddEventScreen())),
        const SizedBox(height: 8),
        _fabSmall(Icons.folder, const Color(0xFFEF5350), () => _navigateTo(const AddProjectScreen())),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'add_activity',
          backgroundColor: const Color(0xFF5C6BC0),
          onPressed: () => _navigateTo(const AddActivityScreen()),
          child: const Icon(Icons.add_task),
        ),
      ],
    );
  }

  Widget _fabSmall(IconData icon, Color color, VoidCallback onPressed) {
    return FloatingActionButton.small(
      heroTag: icon.codePoint.toString(),
      backgroundColor: color,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
