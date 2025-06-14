import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

class AbyssViewModel extends ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;
  String abyssResponse = 'Ask your question...';
  String? errorMessage;
  String? lastAudioUrl;
  bool isListening = false;
  String spokenText = '';
  final AudioPlayer audioPlayer = AudioPlayer();
  final Logger _logger = Logger();

  Future<void> askAbyss() async {
    if (controller.text.trim().isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askAbyss(controller.text.trim());
      abyssResponse = result['answer'] ?? '...';
      lastAudioUrl = result['audioUrl'];
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        _logger.d('Playing audio from $lastAudioUrl');
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      }
    } catch (e) {
      abyssResponse = 'Error!';
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

  Future<void> cancelListening() async {
    // Temporarily disabled
  }

  Future<void> playAudio() async {
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
      _logger.d('Playing audio from $lastAudioUrl');
      try {
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      } catch (audioError) {
        _logger.e('Audio playback error: $audioError');
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
}
