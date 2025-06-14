import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'viewmodels/classic_conch_viewmodel.dart';

class ClassicConchScreen extends StatelessWidget {
  const ClassicConchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClassicConchViewModel(),
      child: Consumer<ClassicConchViewModel>(
        builder: (context, vm, child) => Scaffold(
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
                Text(
                  'Ask a question. Pull the string. Blame the shell.',
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
                    vm.isLoading
                        ? const CircularProgressIndicator(color: Color(0xFFFF6B6B))
                        : Column(
                            children: [
                              Text(
                                vm.conchResponse,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                  color: const Color(0xFFFF6B6B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (vm.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  vm.errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],                              if (vm.lastAudioUrl != null && vm.lastAudioUrl!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          vm.isPlayingAudio ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                          size: 48,
                                          color: const Color(0xFFFF6B6B),
                                        ),
                                        tooltip: vm.isPlayingAudio ? 'Pause Audio' : 'Play Audio',
                                        onPressed: vm.isLoading ? null : vm.playAudio,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        vm.isPlayingAudio ? 'Playing...' : 'Tap to play',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFA0AEC0),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ],
                ),
                ElevatedButton(
                  onPressed: vm.isLoading ? null : vm.pullTheString,
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
        ),
      ),
    );
  }
}
