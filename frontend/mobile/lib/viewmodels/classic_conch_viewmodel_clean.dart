import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';

class ClassicConchViewModel extends ChangeNotifier {
  bool isLoading = false;
  String conchResponse = '...';
  String? errorMessage;
  String? lastAudioUrl;
  bool isPlayingAudio = false;
  bool isListening = false;
  String spokenText = '';
  final AudioPlayer audioPlayer = AudioPlayer();

  ClassicConchViewModel() {
    // Listen to player state changes
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlayingAudio = state == PlayerState.playing;
      notifyListeners();
    });
  }

  Future<void> pullTheString() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askClassicConch();
      conchResponse = result['answer'] ?? '...';
      lastAudioUrl = result['audioUrl'];
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        print('DEBUG: Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.stop();
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          print('DEBUG: Audio playback error: $audioError');
          errorMessage = 'Audio playback failed: $audioError';
        }
      } else {
        print('DEBUG: No audio URL provided');
      }
    } catch (e) {
      print('DEBUG: API call error: $e');
      conchResponse = 'Error!';
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
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty && !isPlayingAudio) {
      print('DEBUG: Playing audio from $lastAudioUrl');
      try {
        await audioPlayer.stop();
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      } catch (audioError) {
        print('DEBUG: Audio playback error: $audioError');
        errorMessage = 'Audio playback failed: ${audioError.toString()}';
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
