import 'package:flutter/material.dart';
import '../today/today_screen.dart';
import '../collab/collab_screen.dart';
import '../calendar/calendar_screen.dart';
import '../analysis/analysis_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    CollabScreen(),
    CalendarScreen(),
    AnalysisScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/profile.png'), // 추후 변경
            ),
            SizedBox(width: 8),
            Text('MOHANA', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline), label: '오늘'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined), label: '협업'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), label: '캘린더'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: '분석'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: '설정'),
        ],
      ),
    );
  }
}