import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'viewmodels/conch_vm.dart';
import 'services/shake_detector_service.dart';
import 'views/screens/classic_conch_screen.dart';
import 'views/screens/culinary_oracle_screen.dart';
import 'views/screens/abyss_screen.dart';

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
        home: const ConchHomePage(),
        debugShowCheckedModeBanner: false,
      ),
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

  static final List<Widget> _screens = [
    const ClassicConchScreen(),
    CulinaryOracleScreen(),
    const AbyssScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _handleAppActions();
  }

  void _handleAppActions() {
    // Listen for app actions from Android voice commands
    const platform = MethodChannel('theconch/app_actions');
    platform.setMethodCallHandler((call) async {
      if (call.method == 'openFeature') {
        final String? feature = call.arguments['feature'];
        _handleFeatureOpen(feature);
      }
    });
  }

  void _handleFeatureOpen(String? feature) {
    print('Voice command received: $feature');

    // Handle different features
    switch (feature?.toLowerCase()) {
      case 'oracle':
      case 'food':
      case 'culinary':
        setState(() {
          _selectedIndex = 1; // Navigate to Food Oracle tab
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening Food Oracle via voice command!'),
          ),
        );
        break;
      case 'abyss':
      case 'ask':
      case 'anything':
        setState(() {
          _selectedIndex = 2; // Navigate to Ask Anything tab
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening Ask Anything via voice command!'),
          ),
        );
        break;
      case 'classic':
      case 'main':
      case 'home':
      default:
        setState(() {
          _selectedIndex = 0; // Navigate to Classic tab
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening Classic Conch via voice command!'),
          ),
        );
        break;
    }
  }

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
      ),
    );
  }
}
