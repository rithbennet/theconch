import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/abyss_viewmodel.dart';

class AbyssScreen extends StatelessWidget {
  const AbyssScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AbyssViewModel(),
      child: Consumer<AbyssViewModel>(
        builder: (context, vm, child) => Scaffold(
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
                      controller: vm.controller,
                      enabled: !vm.isLoading,
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
                      onSubmitted: (_) => vm.askAbyss(),
                    ),
                    const SizedBox(height: 24),
                    vm.isLoading
                        ? const CircularProgressIndicator(color: Color(0xFFFF6B6B))
                        : Column(
                            children: [
                              Text(
                                vm.abyssResponse,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
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
                                ),                              ],
                              if (vm.lastAudioUrl != null && vm.lastAudioUrl!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.play_circle_fill, size: 48, color: Color(0xFFFF6B6B)),
                                    tooltip: 'Play Audio',
                                    onPressed: vm.isLoading ? null : vm.playAudio,
                                  ),
                                ),
                            ],
                          ),
                  ],                ),
                Column(
                  children: [
                    // Voice input section
                    if (vm.isListening) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B263B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF6B6B), width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.mic,
                              color: const Color(0xFFFF6B6B),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Listening to your question...',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF6B6B),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (vm.spokenText.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                vm.spokenText,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFA0AEC0),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: vm.stopListening,
                            icon: const Icon(Icons.stop, size: 16),
                            label: Text(
                              'Ask Abyss',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              foregroundColor: const Color(0xFF0D1B2A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),                          ElevatedButton.icon(
                            onPressed: vm.cancelListening,
                            icon: const Icon(Icons.cancel, size: 16),
                            label: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A5568),
                              foregroundColor: const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: vm.isLoading ? null : vm.askAbyss,
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
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Text(
                                'Ask the Abyss',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: vm.isLoading ? null : vm.startListening,
                            icon: const Icon(Icons.mic, size: 20),
                            label: Text(
                              'Voice',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A5568),
                              foregroundColor: const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
