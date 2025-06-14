import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:audioplayers/audioplayers.dart';

class AbyssViewModel extends ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;
  String abyssResponse = 'Ask your question...';
  String? errorMessage;
  String? lastAudioUrl;
  final AudioPlayer audioPlayer = AudioPlayer();
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
        print('DEBUG: Playing audio from $lastAudioUrl');
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

  Future<void> playAudio() async {
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
      print('DEBUG: Playing audio from $lastAudioUrl');
      await audioPlayer.play(UrlSource(lastAudioUrl!));
    }
  }
  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
}
