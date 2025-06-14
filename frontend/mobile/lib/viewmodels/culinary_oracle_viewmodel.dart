import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:audioplayers/audioplayers.dart';

class CulinaryOracleViewModel extends ChangeNotifier {
  bool isLoading = false;
  String oracleResponse = 'What should I eat?';
  String? errorMessage;
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> consultOracle({String? constraint}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askCulinaryOracle(constraint: constraint);
      oracleResponse = result['answer'] ?? '...';
      if (result['audioUrl'] != null && result['audioUrl'].toString().isNotEmpty) {
        await audioPlayer.play(UrlSource(result['audioUrl']));
      }
    } catch (e) {
      oracleResponse = 'Error!';
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
