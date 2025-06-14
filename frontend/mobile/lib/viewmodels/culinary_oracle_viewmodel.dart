import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:audioplayers/audioplayers.dart';

class CulinaryOracleViewModel extends ChangeNotifier {
  bool isLoading = false;
  String oracleResponse = 'What should I eat?';
  String? errorMessage;
  String? lastAudioUrl;
  final AudioPlayer audioPlayer = AudioPlayer();
  Future<void> consultOracle({String? constraint}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askCulinaryOracle(constraint: constraint);
      oracleResponse = result['answer'] ?? '...';
      lastAudioUrl = result['audioUrl'];
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        print('DEBUG: Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          print('DEBUG: Audio playback error: $audioError');
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

  Future<void> playAudio() async {
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
      print('DEBUG: Playing audio from $lastAudioUrl');
      try {
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      } catch (audioError) {
        print('DEBUG: Audio playback error: $audioError');
      }
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
