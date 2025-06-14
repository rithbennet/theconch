import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';

class AbyssScreen extends StatefulWidget {
  const AbyssScreen({super.key});

  @override
  State<AbyssScreen> createState() => _AbyssScreenState();
}

class _AbyssScreenState extends State<AbyssScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _abyssResponse = 'Ask your question...';

  Future<void> _askAbyss() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await ApiService.askAbyss(_controller.text.trim());
      setState(() {
        _abyssResponse = result['answer'] ?? '...';
      });
      // Optionally play audio from result['audioUrl']
    } catch (e) {
      setState(() {
        _abyssResponse = 'Error!';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          'Ask the Abyss',
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
              'Peer into the unknown. Ask anything.',
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
                          Icons.psychology,
                          size: 80,
                          color: const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 8),
                        Text('🌊', style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 8),
                        Text(
                          'The Abyss',
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
                TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: const Color(0xFFF0F0F0),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your question...',
                    hintStyle: GoogleFonts.poppins(color: const Color(0xFFA0AEC0)),
                    filled: true,
                    fillColor: const Color(0xFF1B263B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onSubmitted: (_) => _askAbyss(),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFFF6B6B))
                    : Text(
                        _abyssResponse,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: const Color(0xFFFF6B6B),
                        ),
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _askAbyss,
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
                  'Ask the Abyss',
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
