import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:theconch/services/shake_detector_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class ClassicConchViewModel extends ChangeNotifier {
  bool isLoading = false;
  String conchResponse = '...';
  String? errorMessage;
  String? lastAudioUrl;
  bool isPlayingAudio = false;  bool isListening = false;  String spokenText = '';
  String recognizedWords = ''; // For debugging display
  String _pendingVoiceQuestion = ''; // Store voice input waiting for shake
  bool _waitingForShake = false; // Flag to indicate shake is needed
  bool _shakeDetected = false; // For shake visual feedback
  bool _hasAskedQuestion = false; // Track if user has asked a question
  final AudioPlayer audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  final ShakeDetectorService _shakeDetector = ShakeDetectorService();
  bool _speechEnabled = false;
  final Logger _logger = Logger();  
  bool get shakeDetected => _shakeDetected;
  bool get waitingForShake => _waitingForShake;
  String get pendingQuestion => _pendingVoiceQuestion;
  bool get hasAskedQuestion => _hasAskedQuestion;

  ClassicConchViewModel() {
    // Listen to player state changes
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlayingAudio = state == PlayerState.playing;
      notifyListeners();
    });    // Initialize shake detection
    _shakeDetector.onShake.listen((_) {
      if (!isLoading) {
        // Always trigger shake animation for UI feedback
        _shakeDetected = true;
        notifyListeners();
        
        // Reset shake indicator after animation duration
        Future.delayed(const Duration(milliseconds: 800), () {
          _shakeDetected = false;
          notifyListeners();
        });
        
        // Business logic for shake handling
        if (_waitingForShake && _pendingVoiceQuestion.isNotEmpty) {
          // User shook after voice input - process the voice question
          _processVoiceQuestion();
        } else {
          // Check if user has asked a question before allowing shake
          if (!_hasAskedQuestion) {
            // Show message that they need to ask a question first
            conchResponse = 'You must ask the conch a question before shaking!';
            return;
          }
          // Direct shake with previous question - use default string pulling
          pullTheString();
        }
      }
    });
    _shakeDetector.startListening();

    // Initialize speech to text
    _initSpeech();
  }
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (errorNotification) {
        _logger.e('Speech recognition error: ${errorNotification.errorMsg}');

        // Delay error messages to give users more time
        Future.delayed(const Duration(seconds: 2), () {
          if (isListening) {
            // Handle different types of errors with user-friendly messages
            String userFriendlyError;
            switch (errorNotification.errorMsg) {
              case 'error_speech_timeout':
                userFriendlyError =
                    'No speech detected. Take your time and try speaking again.';
                break;
              case 'error_no_match':
                userFriendlyError =
                    'Could not understand speech. Please speak more clearly.';
                break;
              case 'error_network':
                userFriendlyError =
                    'Network error - check your internet connection';
                break;
              case 'error_network_timeout':
                userFriendlyError = 'Network timeout - please try again';
                break;
              case 'error_audio':
                userFriendlyError =
                    'Audio error - check microphone permissions';
                break;
              default:
                userFriendlyError =
                    'Speech recognition error. Please try again.';
            }

            errorMessage = userFriendlyError;
            spokenText =
                'Ready to listen again. Tap "Ask with Voice" when ready.';
            isListening = false;
            notifyListeners();
          }
        });
      },
      onStatus: (status) {
        _logger.i('Speech recognition status: $status');
        if (status == 'done' || status == 'notListening') {
          // Don't immediately stop listening, give a grace period
          Future.delayed(const Duration(milliseconds: 500), () {
            if (recognizedWords.isEmpty) {
              isListening = false;
              notifyListeners();
            }
          });
        }
      },
    );
    notifyListeners();
  }
  Future<void> pullTheString() async {
    isLoading = true;
    errorMessage = null;
    _hasAskedQuestion = true; // Mark that a question has been asked
    notifyListeners();
    try {
      final result = await ApiService.askClassicConch();
      conchResponse = result['answer'] ?? '...';
      lastAudioUrl = result['audioUrl'];
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        _logger.d('Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.stop();
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          _logger.e('Audio playback error: $audioError');
          errorMessage = 'Audio playback failed: $audioError';
        }
      } else {
        _logger.w('No audio URL provided');
      }
    } catch (e) {
      _logger.e('API call error: $e');
      conchResponse = 'Error!';
      errorMessage = e.toString();    } finally {
      isLoading = false;
      _hasAskedQuestion = false; // Reset after answer is given - user must ask new question
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
      spokenText = 'Listening... Take your time, speak clearly';
      recognizedWords = '';
      errorMessage = null;
      notifyListeners();

      try {
        await _speechToText.listen(
          onResult: (result) {
            recognizedWords = result.recognizedWords;
            if (recognizedWords.isNotEmpty) {
              spokenText = 'You said: "$recognizedWords"';

              // Only auto-stop if we have a complete sentence and final result
              if (result.finalResult && recognizedWords.length > 3) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (isListening && recognizedWords.isNotEmpty) {
                    stopListening();
                  }
                });
              }
            } else {
              spokenText = 'Listening... Take your time, speak clearly';
            }
            notifyListeners();
          },
          listenFor: const Duration(seconds: 30), // Much longer timeout
          pauseFor: const Duration(
            seconds: 5,
          ), // Longer pause detection to allow slow speech
          localeId: 'en_US',
          listenOptions: SpeechListenOptions(
            partialResults: true,
            cancelOnError: false, // Don't cancel immediately on errors
            listenMode: ListenMode.confirmation,
          ),
        );
      } catch (e) {
        _logger.e('Speech listening error: $e');
        errorMessage = 'Failed to start speech recognition: $e';
        isListening = false;
        notifyListeners();
      }
    }
  }
  Future<void> stopListening() async {
    if (isListening) {
      await _speechToText.stop();
      isListening = false;      if (recognizedWords.isNotEmpty) {
        _pendingVoiceQuestion = recognizedWords;
        _waitingForShake = true;
        _hasAskedQuestion = true; // Mark that a question has been asked via voice
        spokenText = 'Great! Now shake your phone to get the Conch\'s answer!';
        conchResponse = 'Shake for your answer...';
      } else {
        spokenText = 'No speech detected. Try again.';
        _waitingForShake = false;
      }
      notifyListeners();
    }
  }

  Future<void> _processVoiceQuestion() async {
    if (_pendingVoiceQuestion.isNotEmpty) {
      _waitingForShake = false;
      await pullTheStringWithVoice(_pendingVoiceQuestion);
      _pendingVoiceQuestion = '';
      recognizedWords = '';
      spokenText = '';
      notifyListeners();
    }
  }

  Future<void> pullTheStringWithVoice(String voiceQuestion) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService.askClassicConch(question: voiceQuestion);
      conchResponse = result['answer'] ?? '...';
      lastAudioUrl = result['audioUrl'];
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        _logger.d('Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.stop();
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          _logger.e('Audio playback error: $audioError');
          errorMessage = 'Audio playback failed: $audioError';
        }
      } else {
        _logger.w('No audio URL provided');
      }
    } catch (e) {
      _logger.e('API call error: $e');
      conchResponse = 'Error!';
      errorMessage = e.toString();    } finally {
      isLoading = false;
      spokenText = '';
      _hasAskedQuestion = false; // Reset after answer is given - user must ask new question
      notifyListeners();
    }
  }

  Future<void> playAudio() async {
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty && !isPlayingAudio) {
      _logger.d('Playing audio from $lastAudioUrl');
      try {
        await audioPlayer.stop();
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      } catch (audioError) {
        _logger.e('Audio playback error: $audioError');
        errorMessage = 'Audio playback failed: ${audioError.toString()}';
        notifyListeners();
      }
    }
  }
  // Reset speech recognition state
  void resetSpeechState() {
    isListening = false;
    _waitingForShake = false;
    _pendingVoiceQuestion = '';
    spokenText = '';
    recognizedWords = '';
    errorMessage = null;
    conchResponse = '...';
    _hasAskedQuestion = false; // Reset question state
    _speechToText.stop();
    notifyListeners();
  }
  @override
  void dispose() {
    audioPlayer.dispose();
    _speechToText.stop();
    _shakeDetector.dispose();
    super.dispose();
  }
}
