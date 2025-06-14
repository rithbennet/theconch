import 'package:flutter/foundation.dart';
import '../services/shake_detector_service.dart';
import 'dart:math';

class ConchViewModel extends ChangeNotifier {
  final ShakeDetectorService _shakeDetector;
  final Random _random = Random();
  final List<String> _answers = ['Yes.', 'No.', 'Try Again.'];
  
  String _currentAnswer = "...";
  int _currentIndex = 0; 
  
  String get currentAnswer => _currentAnswer;
  int get currentIndex => _currentIndex;

  ConchViewModel(this._shakeDetector) {
    _shakeDetector.onShake.listen((_) {
      generateAnswer();
    });
    _shakeDetector.startListening();
  }

  void generateAnswer() {
    _currentAnswer = _answers[_random.nextInt(_answers.length)];
    notifyListeners();
  }

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
  @override
  void dispose() {
    _shakeDetector.dispose();
    super.dispose();
  }
}