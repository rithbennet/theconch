import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'viewmodels/conch_vm.dart';
import 'views/screens/home_screen.dart';
import 'services/shake_detector_service.dart';
=======
import 'classic_conch_screen.dart';
import 'culinary_oracle_screen.dart';
import 'abyss_screen.dart';
>>>>>>> main

void main() {
  runApp(const TheConchApp());
}

class TheConchApp extends StatelessWidget {
  const TheConchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConchViewModel(ShakeDetectorService()),
      child: MaterialApp(
        title: 'TheConch Super App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D1B2A),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
<<<<<<< HEAD
        home: const ConchHomePage(),
        debugShowCheckedModeBanner: false,
=======
        useMaterial3: true,
      ),
      home: const ConchHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConchHomePage extends StatefulWidget {
  const ConchHomePage({super.key});

  @override
  State<ConchHomePage> createState() => _ConchHomePageState();
}

class _ConchHomePageState extends State<ConchHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    ClassicConchScreen(),
    CulinaryOracleScreen(),
    AbyssScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B263B),
        selectedItemColor: const Color(0xFFFF6B6B),
        unselectedItemColor: const Color(0xFFA0AEC0),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            activeIcon: Icon(Icons.question_answer),
            label: 'Classic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Food Oracle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'Ask Anything',
          ),
        ],
>>>>>>> main
      ),
    );
  }
}