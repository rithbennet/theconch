import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/conch_vm.dart';
import 'views/screens/home_screen.dart';
import 'services/shake_detector_service.dart';

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