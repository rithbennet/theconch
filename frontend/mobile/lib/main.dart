import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

void main() {
  runApp(const TheConchApp());
}

class TheConchApp extends StatelessWidget {
  const TheConchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

class ConchHomePage extends StatefulWidget {
  const ConchHomePage({super.key});

  @override
  State<ConchHomePage> createState() => _ConchHomePageState();
}

class _ConchHomePageState extends State<ConchHomePage> {
  String conchAnswer = "...";
  int currentIndex = 0;
  final Random _random = Random();
  final List<String> _answers = ['Yes.', 'No.', 'Try Again.'];

  void _pullTheString() {
    setState(() {
      conchAnswer = _answers[_random.nextInt(_answers.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'TheConch',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: const Color(0xFFF0F0F0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top instructional text
            Text(
              'Ask a question. Pull the string. Blame the shell.',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFA0AEC0),
              ),
              textAlign: TextAlign.center,
            ),

            // Central Conch Display
            Column(
              children: [
                // The Conch Image
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(125),
                    color: const Color(0xFF1B263B),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 80,
                          color: const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 8),
                        Text('🐚', style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 8),
                        Text(
                          'TheConch',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA0AEC0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Answer Display Area
                Text(
                  conchAnswer,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: const Color(0xFFFF6B6B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Bottom Action Button
            ElevatedButton(
              onPressed: _pullTheString,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: const Color(0xFF0D1B2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 8,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Text(
                  'Pull the String',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B263B),
        selectedItemColor: const Color(0xFFFF6B6B),
        unselectedItemColor: const Color(0xFFA0AEC0),
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
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
