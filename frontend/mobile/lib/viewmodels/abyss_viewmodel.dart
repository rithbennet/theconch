import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:theconch/services/shake_detector_service.dart';
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
  bool _hasAskedQuestion = false; // Track if user has asked a question
  final AudioPlayer audioPlayer = AudioPlayer();
  final ShakeDetectorService _shakeDetector = ShakeDetectorService();
  final Logger _logger = Logger();

  bool get hasAskedQuestion => _hasAskedQuestion;

  AbyssViewModel() {
    // Initialize shake detection
    _shakeDetector.onShake.listen((_) {
      if (!isLoading) {
        // Check if user has asked a question before allowing shake
        if (!_hasAskedQuestion || controller.text.trim().isEmpty) {
          // Show message that they need to ask a question first
          abyssResponse = 'You must ask the abyss a question before shaking!';
          notifyListeners();
          return;
        }
        // User has asked a question and text field has content, allow shake
        askAbyss();
      }
    });
    _shakeDetector.startListening();
  }
  Future<void> askAbyss() async {
    if (controller.text.trim().isEmpty) return;
    isLoading = true;
    errorMessage = null;
    _hasAskedQuestion = true; // Mark that a question has been asked
    notifyListeners();    try {
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
      _hasAskedQuestion = false; // Reset after answer is given - user must ask new question
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

  void resetState() {
    controller.clear();
    abyssResponse = 'Ask your question...';
    errorMessage = null;
    _hasAskedQuestion = false; // Reset question state
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    _shakeDetector.dispose();
    super.dispose();
  }
}
