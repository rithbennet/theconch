import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/abyss_viewmodel.dart';
import '../widgets/shake_anim.dart';

class AbyssScreen extends StatelessWidget {
  const AbyssScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AbyssViewModel(),
      child: Consumer<AbyssViewModel>(
        builder:
            (context, vm, child) => Scaffold(
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
              ),              body: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                        AppBar().preferredSize.height - 
                        MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text(
                      'Speak your question, then shake to consult the abyss.',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFA0AEC0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Column(
                      children: [                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xFF1B263B),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF6B6B,
                                ).withValues(alpha: .3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [                                Icon(
                                  Icons.psychology,
                                  size: 60,
                                  color: const Color(0xFFFF6B6B),
                                ),
                                const SizedBox(height: 8),
                                ShakeAnimationWidget(
                                  isShaking: vm.shakeDetected,
                                  child: Text(
                                    '🌊',
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'The Abyss',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFA0AEC0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),                        vm.isLoading
                            ? const CircularProgressIndicator(
                              color: Color(0xFFFF6B6B),
                            )
                            : Column(
                              children: [
                                Text(
                                  vm.abyssResponse,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
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
                                ],
                                if (vm.lastAudioUrl != null &&
                                    vm.lastAudioUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.play_circle_fill,
                                        size: 48,
                                        color: Color(0xFFFF6B6B),
                                      ),
                                      tooltip: 'Play Audio',
                                      onPressed:
                                          vm.isLoading ? null : vm.playAudio,
                                    ),
                                  ),
                              ],
                            ),
                      ],
                    ),
                    Column(
                      children: [                        // Voice input section
                        if (vm.isListening) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B263B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6B6B),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.mic,
                                  color: const Color(0xFFFF6B6B),
                                  size: 32,
                                ),                                const SizedBox(height: 8),
                                Text(
                                  'Listening to your question...',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF6B6B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),                                const SizedBox(height: 8),
                                Text(
                                  'Take your time - you have up to 60 seconds\nTap "Stop Recording" when you\'re done',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFA0AEC0),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
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
                                  'Stop Recording',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B6B),
                                  foregroundColor: const Color(0xFF0D1B2A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
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
                        ] else if (vm.waitingForShake) ...[
                          // Show waiting for shake state
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B263B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4ECDC4),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.vibration,
                                  color: const Color(0xFF4ECDC4),
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Question Recorded!',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF4ECDC4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Shake your device to consult the abyss',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFA0AEC0),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (vm.pendingQuestion.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D1B2A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '"${vm.pendingQuestion}"',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFF0F0F0),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
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
                                onPressed: vm.resetState,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: Text(
                                  'Record New Question',
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
                          // Default state - show voice recording button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: vm.isLoading ? null : vm.startListening,
                                icon: const Icon(Icons.mic, size: 20),
                                label: Text(
                                  'Record Question',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                  foregroundColor: const Color(0xFF0D1B2A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  elevation: 8,
                                ),
                              ),
                            ],                          ),
                          const SizedBox(height: 16),
                          // Just show instruction for voice input
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tap the button above to record your question',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFFA0AEC0),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
