import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:logger/logger.dart';

class ShakeDetectorService {
  final StreamController<void> _shakeController = StreamController<void>();
  StreamSubscription<AccelerometerEvent>? _subscription;
  Timer? _shakeEndTimer;

  final double shakeThreshold = 15.0;
  final Duration shakeEndDelay = const Duration(milliseconds: 500);
  final Duration minShakeDuration = const Duration(milliseconds: 500);

  DateTime? _shakeStartTime;
  DateTime? _lastShakeTime;
  bool _isShaking = false;

  final Logger _logger = Logger();

  Stream<void> get onShake => _shakeController.stream;

  void startListening() {
    _subscription = accelerometerEventStream().listen((event) {
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

    if (!_isShaking) {
      _isShaking = true;
      _shakeStartTime = now;
      _logger.d("Shake started!");
    }

    _lastShakeTime = now;

    _shakeEndTimer?.cancel();
    _shakeEndTimer = Timer(shakeEndDelay, () {
      _handleShakeEnded();
    });
  }

  void _handleShakeEnded() {
    if (_isShaking && _shakeStartTime != null && _lastShakeTime != null) {
      final shakeDuration = _lastShakeTime!.difference(_shakeStartTime!);

      if (shakeDuration >= minShakeDuration) {
        _logger.d("Shake ended! Duration: ${shakeDuration.inMilliseconds}ms");
        _shakeController.add(null);
      }
    }

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
