import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class ShakeDetectorService {
  final StreamController<void> _shakeController = StreamController<void>();
  StreamSubscription<AccelerometerEvent>? _subscription; // Add this line
  Timer? _shakeEndTimer; // Rename from _shakeTimer

  final double shakeThreshold = 15.0;
  final Duration shakeEndDelay = const Duration(milliseconds: 500);
  final Duration minShakeDuration = const Duration(milliseconds: 500);

  DateTime? _shakeStartTime;
  DateTime? _lastShakeTime;
  bool _isShaking = false;

  Stream<void> get onShake => _shakeController.stream;

  void startListening() {
    _subscription = accelerometerEvents.listen((event) {
      final acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (acceleration > shakeThreshold) {
        _handleShakeDetected();
      }
    });
  }

  void _handleShakeDetected() {
    final now = DateTime.now();

    // Start shaking session
    if (!_isShaking) {
      _isShaking = true;
      _shakeStartTime = now;
      print("Shake started!"); // Debug print
    }

    // Update last shake time
    _lastShakeTime = now;

    // Cancel previous timer and start new one
    _shakeEndTimer?.cancel();
    _shakeEndTimer = Timer(shakeEndDelay, () {
      _handleShakeEnded();
    });
  }

  void _handleShakeEnded() {
    if (_isShaking && _shakeStartTime != null && _lastShakeTime != null) {
      final shakeDuration = _lastShakeTime!.difference(_shakeStartTime!);

      // Only trigger if shake lasted long enough
      if (shakeDuration >= minShakeDuration) {
        print(
          "Shake ended! Duration: ${shakeDuration.inMilliseconds}ms",
        ); // Debug print
        _shakeController.add(null);
      }
    }

    // Reset state
    _isShaking = false;
    _shakeStartTime = null;
    _lastShakeTime = null;
  }

  void dispose() {
    _subscription?.cancel();
    _shakeEndTimer?.cancel();
    _shakeController.close();
  }
}
