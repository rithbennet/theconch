import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';

class CulinaryOracleScreen extends StatefulWidget {
  const CulinaryOracleScreen({super.key});

  @override
  State<CulinaryOracleScreen> createState() => _CulinaryOracleScreenState();
}

class _CulinaryOracleScreenState extends State<CulinaryOracleScreen> {
  bool _isLoading = false;
  String _oracleResponse = 'What should I eat?';

  Future<void> _consultOracle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await ApiService.askCulinaryOracle();
      setState(() {
        _oracleResponse = result['answer'] ?? '...';
      });
      // Optionally play audio from result['audioUrl']
    } catch (e) {
      setState(() {
        _oracleResponse = 'Error!';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          'Culinary Oracle',
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
            Text(
              'Hungry? Let the Oracle decide your next meal!',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFA0AEC0),
              ),
              textAlign: TextAlign.center,
            ),
            Column(
              children: [
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
                          Icons.restaurant_menu,
                          size: 80,
                          color: const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 8),
                        Text('🍲', style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 8),
                        Text(
                          'Culinary Oracle',
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
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFFF6B6B))
                    : Text(
                        _oracleResponse,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: const Color(0xFFFF6B6B),
                        ),
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _consultOracle,
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
                  'Consult the Oracle',
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
    );
  }
}
