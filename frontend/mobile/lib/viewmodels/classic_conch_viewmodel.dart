import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:audioplayers/audioplayers.dart';

class ClassicConchViewModel extends ChangeNotifier {
  bool isLoading = false;
  String conchResponse = '...';
  String? errorMessage;
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> pullTheString() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askClassicConch();
      conchResponse = result['answer'] ?? '...';
      if (result['audioUrl'] != null && result['audioUrl'].toString().isNotEmpty) {
        await audioPlayer.play(UrlSource(result['audioUrl']));
      }
    } catch (e) {
      conchResponse = 'Error!';
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
