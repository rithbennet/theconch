import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:theconch/services/shake_detector_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

class CulinaryOracleViewModel extends ChangeNotifier {
  bool isLoading = false;
  String oracleResponse = 'What should I eat?';
  String? errorMessage;
  String? lastAudioUrl;
  bool isListening = false;
  bool _hasAskedQuestion= false;  String spokenText = '';
  String _pendingVoiceQuestion = ''; // Store voice input waiting for shake
  bool _waitingForShake = false; // Flag to indicate shake is needed
  bool _shakeDetected = false; // For animation purposes
  
  // Location and restaurant data
  String? _restaurantName;
  String? _restaurantAddress;
  String? _googleMapsUrl;
  double? _restaurantLatitude;
  double? _restaurantLongitude;
    final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer shakeAudioPlayer = AudioPlayer(); // Separate player for shake sound
  final ShakeDetectorService _shakeDetector = ShakeDetectorService();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  final Logger logger = Logger();
    bool get waitingForShake => _waitingForShake;
  bool get shakeDetected => _shakeDetected;
  String get pendingQuestion => _pendingVoiceQuestion;
  bool get hasAskedQuestion => _hasAskedQuestion;
  String? get restaurantName => _restaurantName;
  String? get restaurantAddress => _restaurantAddress;
  String? get googleMapsUrl => _googleMapsUrl;
  double? get restaurantLatitude => _restaurantLatitude;
  double? get restaurantLongitude => _restaurantLongitude;

  CulinaryOracleViewModel() {    // Initialize shake detection
    _shakeDetector.onShake.listen((_) {
      // Trigger shake animation
      _shakeDetected = true;
      notifyListeners();
      
      // Reset animation after a delay
      Future.delayed(const Duration(milliseconds: 800), () {
        _shakeDetected = false;
        notifyListeners();
      });
      
      if (_waitingForShake && !isLoading) {
        // User shook after voice input - now get the answer
        _processVoiceQuestion();
      } else if (!isLoading && !_waitingForShake) {
        // Check if user has asked a question before allowing shake
        if (!_hasAskedQuestion) {
          // Show message that they need to ask a question first
          oracleResponse = 'You must ask the conch a question before shaking!';
          notifyListeners();
          return;
        }
        // Direct shake with previous question - use default oracle consultation
        consultOracle();
      }    });

    // Listen for shake start to play sound
    _shakeDetector.onShakeStart.listen((_) {
      _playShakeSound();
    });

    // Listen for shake end to stop sound
    _shakeDetector.onShakeEnd.listen((_) {
      _stopShakeSound();
    });

    _shakeDetector.startListening();
    
    // Initialize speech to text
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (errorNotification) {
        logger.e('Speech recognition error: ${errorNotification.errorMsg}');
        errorMessage = 'Speech recognition error. Please try again.';
        isListening = false;
        notifyListeners();
      },
      onStatus: (status) {
        logger.d('Speech recognition status: $status');
        if (status == 'done' || status == 'notListening') {
          if (isListening) {
            isListening = false;
            notifyListeners();
          }
        }
      },
    );
  }
  Future<void> consultOracle({String? constraint}) async {
    isLoading = true;
    errorMessage = null;
    _hasAskedQuestion = true;
    // Clear previous restaurant data
    _restaurantName = null;
    _restaurantAddress = null;
    _googleMapsUrl = null;
    _restaurantLatitude = null;
    _restaurantLongitude = null;
    notifyListeners();
    
    try {
      // Get current location
      Position? position = await _getCurrentLocation();
      if (position == null) {
        // If location failed, use fallback method
        final result = await ApiService.askCulinaryOracle(constraint: constraint);
        oracleResponse = result['answer'] ?? '...';
        lastAudioUrl = result['audioUrl'];
      } else {
        // Use location-based API
        final result = await ApiService.askCulinaryOracleWithLocation(
          question: constraint,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        oracleResponse = result['answer'] ?? '...';
        lastAudioUrl = result['audioUrl'];
        _restaurantName = result['restaurantName'];
        _restaurantAddress = result['address'];
        _googleMapsUrl = result['googleMapsUrl'];
        _restaurantLatitude = result['latitude'];
        _restaurantLongitude = result['longitude'];
      }
      
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        logger.d('Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          logger.e('Audio playback error: $audioError');
        }
      }    } catch (e) {
      logger.e('Error in consultOracle: $e');
      
      // Provide user-friendly error messages
      if (e.toString().contains('Network error') || e.toString().contains('Failed to connect')) {
        oracleResponse = 'Connection failed!';
        errorMessage = 'Unable to reach the oracle. Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        oracleResponse = 'Request timed out!';
        errorMessage = 'The oracle is taking too long to respond. Please try again.';
      } else {
        oracleResponse = 'Something went wrong!';
        errorMessage = 'An unexpected error occurred. Please try again later.';
      }
    } finally {
      isLoading = false;
      _hasAskedQuestion = false; // Reset after answer is given - user must ask new question
      notifyListeners();
    }
  }

  Future<void> _processVoiceQuestion() async {
    if (_pendingVoiceQuestion.isNotEmpty) {
      _waitingForShake = false;
      await consultOracle(constraint: _pendingVoiceQuestion);
      _pendingVoiceQuestion = '';
      spokenText = '';
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      errorMessage = 'Microphone permission required for voice input';
      notifyListeners();
      return;
    }

    if (!_speechEnabled) {
      errorMessage = 'Speech recognition not available';
      notifyListeners();
      return;
    }

    if (!isListening) {
      isListening = true;
      spokenText = 'Listening for your food preferences...';
      _pendingVoiceQuestion = '';
      _waitingForShake = false;
      errorMessage = null;
      notifyListeners();

      try {
        await _speechToText.listen(
          onResult: (result) {
            _pendingVoiceQuestion = result.recognizedWords;
            if (_pendingVoiceQuestion.isNotEmpty) {
              spokenText = 'You said: "$_pendingVoiceQuestion"';
              
              // Auto-stop if we have a complete sentence
              if (result.finalResult && _pendingVoiceQuestion.length > 3) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (isListening) {
                    stopListening();
                  }
                });
              }
            }
            notifyListeners();
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: 'en_US',
          cancelOnError: false,
        );
      } catch (e) {
        logger.e('Speech listening error: $e');
        errorMessage = 'Failed to start speech recognition: $e';
        isListening = false;
        notifyListeners();
      }
    }
  }

  Future<void> stopListening() async {
    if (isListening) {
      await _speechToText.stop();
      isListening = false;
      
      if (_pendingVoiceQuestion.isNotEmpty) {
        _waitingForShake = true;
        _hasAskedQuestion = true; 

        spokenText = 'Shake to hear the wisdom of the conch';
        oracleResponse = 'Shake for your answer mortal...';
      } else {
        spokenText = 'No speech detected. Try again.';
        _waitingForShake = false;
      }
      notifyListeners();
    }
  }
  void resetVoiceState() {
    isListening = false;
    _waitingForShake = false;
    _pendingVoiceQuestion = '';
    spokenText = '';
    errorMessage = null;
    oracleResponse = 'What should I eat?';
    _hasAskedQuestion = false;
    // Clear restaurant data
    _restaurantName = null;
    _restaurantAddress = null;
    _googleMapsUrl = null;
    _restaurantLatitude = null;
    _restaurantLongitude = null;
    _speechToText.stop();
    notifyListeners();
  }

  Future<void> playAudio() async {
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
      logger.d('Playing audio from $lastAudioUrl');
      try {
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      } catch (audioError) {
        logger.e('Audio playback error: $audioError');
      }
    }
  } 

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage = 'Location services are disabled. Please enable them.';
        notifyListeners();
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage = 'Location permissions are denied';
          notifyListeners();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage = 'Location permissions are permanently denied, we cannot request permissions.';
        notifyListeners();
        return null;
      }      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      logger.d('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      logger.e('Error getting location: $e');
      errorMessage = 'Failed to get location: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<void> openGoogleMaps() async {
    if (_googleMapsUrl != null && _googleMapsUrl!.isNotEmpty) {
      try {
        final Uri url = Uri.parse(_googleMapsUrl!);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $_googleMapsUrl');
        }
      } catch (e) {
        logger.e('Error launching Google Maps: $e');
        errorMessage = 'Could not open Google Maps';
        notifyListeners();
      }
    } else if (_restaurantLatitude != null && _restaurantLongitude != null) {
      // Fallback: create Google Maps URL with coordinates
      final String mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$_restaurantLatitude,$_restaurantLongitude';
      try {
        final Uri url = Uri.parse(mapsUrl);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $mapsUrl');
        }
      } catch (e) {
        logger.e('Error launching Google Maps with coordinates: $e');
        errorMessage = 'Could not open Google Maps';
        notifyListeners();
      }
    }  }

  Future<void> _playShakeSound() async {
    try {
      await shakeAudioPlayer.play(AssetSource('audio/Shake Sound Effect.mp3'));
      await shakeAudioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      logger.e('Error playing shake sound: $e');
    }
  }

  Future<void> _stopShakeSound() async {
    try {
      await shakeAudioPlayer.stop();
    } catch (e) {
      logger.e('Error stopping shake sound: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    shakeAudioPlayer.dispose();
    _shakeDetector.dispose();
    _speechToText.stop();
    super.dispose();
  }
}
