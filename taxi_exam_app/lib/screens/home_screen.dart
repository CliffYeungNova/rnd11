import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'locations_screen.dart';
import 'routes_screen.dart';
import 'memorization_guide_screen.dart';
import 'location_quiz_screen.dart';
import 'route_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const LocationsScreen(),
    const RoutesScreen(),
    const MemorizationGuideScreen(),
    const LocationQuizScreen(),
    const RouteQuizScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: IndexedStack(
            index: appState.currentTabIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: appState.currentTabIndex,
            onDestinationSelected: (index) {
              appState.setCurrentTabIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: '地方',
              ),
              NavigationDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route),
                label: '路線',
              ),
              NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book),
                label: '溫習指南',
              ),
              NavigationDestination(
                icon: Icon(Icons.quiz_outlined),
                selectedIcon: Icon(Icons.quiz),
                label: '練習',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: '學習',
              ),
            ],
          ),
        );
      },
    );
  }
}