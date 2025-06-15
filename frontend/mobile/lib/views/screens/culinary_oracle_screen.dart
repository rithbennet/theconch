import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/culinary_oracle_viewmodel.dart';

class CulinaryOracleScreen extends StatelessWidget {
  const CulinaryOracleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CulinaryOracleViewModel(),
      child: Consumer<CulinaryOracleViewModel>(
        builder: (context, vm, child) => Scaffold(
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
          body: SingleChildScrollView(
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
                                  Icons.restaurant_menu,
                                  size: 60,
                                  color: const Color(0xFFFF6B6B),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '🍲',
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Culinary Oracle',
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
                                    vm.oracleResponse,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: const Color(0xFFFF6B6B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  // Restaurant information or no food message
                                  if (vm.restaurantName != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B263B),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF4ECDC4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.restaurant,
                                                color: const Color(0xFF4ECDC4),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => vm.openGoogleMaps(),
                                                  child: Text(
                                                    vm.restaurantName!,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                      color: const Color(0xFF4ECDC4),
                                                      decoration: TextDecoration.underline,
                                                      decorationColor: const Color(0xFF4ECDC4),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (vm.restaurantAddress != null) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: const Color(0xFFA0AEC0),
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    vm.restaurantAddress!,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: const Color(0xFFA0AEC0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ] else if (vm.oracleResponse != 'What should I eat?' && 
                                            vm.oracleResponse != 'Shake for your answer mortal...' &&
                                            !vm.isLoading) ...[
                                    // Show "no food" message when oracle has responded but no restaurant found
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B263B),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFA0AEC0),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.sentiment_dissatisfied,
                                            color: const Color(0xFFA0AEC0),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'no food bohoo :(',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: const Color(0xFFA0AEC0),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                      children: [
                        if (vm.waitingForShake) ...[
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
                                  'Preference Recorded!',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF4ECDC4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Shake your device to consult the oracle',
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
                                onPressed: vm.resetVoiceState,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: Text(
                                  'New Preference',
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
                                Icon(
                                  Icons.mic,
                                  color: const Color(0xFFFF6B6B),
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Listening for your food preferences...',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF6B6B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tell me what you\'re craving or dietary needs',
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
                                onPressed: vm.resetVoiceState,
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
                              ElevatedButton.icon(
                                onPressed: vm.isLoading ? null : vm.startListening,
                                icon: const Icon(Icons.mic, size: 20),
                                label: Text(
                                  'Voice Preferences',
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
                                'OR tap below for a surprise',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFFA0AEC0),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: vm.isLoading ? null : vm.consultOracle,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B6B),
                                  foregroundColor: const Color(0xFF0D1B2A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  elevation: 8,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    'Surprise Me!',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
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
        ),
      ),
    );
  }
}
