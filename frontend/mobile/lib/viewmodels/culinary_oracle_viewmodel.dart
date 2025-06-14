import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

class CulinaryOracleViewModel extends ChangeNotifier {
  bool isLoading = false;
  String oracleResponse = 'What should I eat?';
  String? errorMessage;
  String? lastAudioUrl;
  bool isListening = false;
  String spokenText = '';
  final AudioPlayer audioPlayer = AudioPlayer();
  final Logger logger = Logger();

  Future<void> consultOracle({String? constraint}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askCulinaryOracle(constraint: constraint);
      oracleResponse = result['answer'] ?? '...';
      lastAudioUrl = result['audioUrl'];
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        logger.d('Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          logger.e('Audio playback error: $audioError');
          errorMessage = 'Audio playback failed: $audioError';
        }
      }
    } catch (e) {
      oracleResponse = 'Error!';
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    errorMessage = 'Voice input temporarily disabled for testing';
    notifyListeners();
  }

  Future<void> stopListening() async {
    // Temporarily disabled
  }

  Future<void> playAudio() async {
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
      logger.d('Playing audio from $lastAudioUrl');
      try {
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      } catch (audioError) {
        logger.e('Audio playback error: $audioError');
      }
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
