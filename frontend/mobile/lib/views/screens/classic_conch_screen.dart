import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/classic_conch_viewmodel.dart';
import '../widgets/shake_anim.dart';

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
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    AppBar().preferredSize.height - 
                    MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Ask a question with voice, then shake the phone.',
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
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xFF1B263B),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withValues(alpha: .3),
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
                                  size: 60,
                                  color: const Color(0xFFFF6B6B),
                                ),                                const SizedBox(height: 8),
                                ShakeAnimationWidget(
                                  isShaking: vm.shakeDetected,
                                  child: Text(
                                    '🐚',
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'TheConch',
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
                        const SizedBox(height: 24),
                        vm.isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFFFF6B6B),
                              )
                            : Column(
                                children: [
                                  Text(
                                    vm.conchResponse,
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
                                    ),
                                  ],
                                  if (vm.lastAudioUrl != null &&
                                      vm.lastAudioUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              vm.isPlayingAudio
                                                  ? Icons.pause_circle_filled
                                                  : Icons.play_circle_fill,
                                              size: 40,
                                              color: const Color(0xFFFF6B6B),
                                            ),
                                            tooltip: vm.isPlayingAudio
                                                ? 'Pause Audio'
                                                : 'Play Audio',
                                            onPressed: vm.isLoading ? null : vm.playAudio,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            vm.isPlayingAudio
                                                ? 'Playing...'
                                                : 'Tap to play',
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
                    Column(
                      children: [
                        // Voice input section
                        if (vm.waitingForShake) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B263B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF68D391),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.vibration,
                                  color: const Color(0xFF68D391),
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '🤳 Shake your phone now!',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF68D391),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vm.spokenText,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFA0AEC0),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (vm.pendingQuestion.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D3748),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Your question: "${vm.pendingQuestion}"',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF63B3ED),
                                        fontSize: 11,
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
                          ElevatedButton(
                            onPressed: vm.resetSpeechState,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF718096),
                              foregroundColor: const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                'Cancel & Start Over',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ),
                          ),
                        ] else if (vm.isListening) ...[
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
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  child: Icon(
                                    Icons.mic,
                                    color: vm.recognizedWords.isNotEmpty
                                        ? const Color(0xFF68D391)
                                        : const Color(0xFFFF6B6B),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  vm.recognizedWords.isNotEmpty
                                      ? 'Got it! Keep talking...'
                                      : 'Listening...',
                                  style: GoogleFonts.poppins(
                                    color: vm.recognizedWords.isNotEmpty
                                        ? const Color(0xFF68D391)
                                        : const Color(0xFFFF6B6B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Take your time - you have 30 seconds',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFA0AEC0),
                                    fontSize: 11,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: vm.stopListening,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A5568),
                                  foregroundColor: const Color(0xFFF0F0F0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Stop & Ask Conch',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: vm.resetSpeechState,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF718096),
                                  foregroundColor: const Color(0xFFF0F0F0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: vm.isLoading ? null : vm.startListening,
                                icon: const Icon(Icons.mic, size: 20),
                                label: Text(
                                  'Ask with Voice',
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
                            ],
                          ),
                          const SizedBox(height: 16),
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
                          if (vm.errorMessage != null &&
                              vm.errorMessage!.contains('Speech')) ...[
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: vm.resetSpeechState,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF718096),
                                foregroundColor: const Color(0xFFF0F0F0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                'Reset & Try Again',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
