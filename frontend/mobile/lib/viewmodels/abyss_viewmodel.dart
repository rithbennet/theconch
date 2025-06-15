import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:theconch/services/shake_detector_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class AbyssViewModel extends ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;
  String abyssResponse = 'Ask your question...';
  String? errorMessage;
  String? lastAudioUrl;
  bool isListening = false;
  String spokenText = '';
  String recognizedWords = ''; // For debugging display
  String _pendingVoiceQuestion = ''; // Store voice input waiting for shake
  bool _waitingForShake = false; // Flag to indicate shake is needed
  bool _hasAskedQuestion = false; // Track if user has asked a question
  final AudioPlayer audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  final ShakeDetectorService _shakeDetector = ShakeDetectorService();
  bool _speechEnabled = false;
  final Logger _logger = Logger();

  bool get hasAskedQuestion => _hasAskedQuestion;
  bool get waitingForShake => _waitingForShake;
  String get pendingQuestion => _pendingVoiceQuestion;  AbyssViewModel() {
    // Initialize shake detection
    _shakeDetector.onShake.listen((_) {
      if (!isLoading) {
        if (_waitingForShake && _pendingVoiceQuestion.isNotEmpty) {
          // User shook after voice input - process the voice question
          _processVoiceQuestion();
        } else {
          // Show message that they need to record a question first
          abyssResponse = 'You must record a question with voice first, then shake!';
          notifyListeners();
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

        Future.delayed(const Duration(seconds: 2), () {
          if (isListening) {
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
            spokenText = 'Ready to listen again. Tap "Record Question" when ready.';
            isListening = false;
            notifyListeners();
          }
        });
      },
      onStatus: (status) {
        _logger.i('Speech recognition status: $status');
        if (status == 'done' || status == 'notListening') {
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

  Future<void> _processVoiceQuestion() async {
    if (_pendingVoiceQuestion.isNotEmpty) {
      _waitingForShake = false;
      await askAbyssWithVoice(_pendingVoiceQuestion);
      _pendingVoiceQuestion = '';
      recognizedWords = '';
      spokenText = '';
      notifyListeners();
    }
  }

  Future<void> askAbyssWithVoice(String voiceQuestion) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      final result = await ApiService.askAbyss(voiceQuestion);
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
      spokenText = '';
      _hasAskedQuestion = false;
      notifyListeners();
    }
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
      spokenText = 'Listening... Speak your question clearly';
      recognizedWords = '';
      errorMessage = null;
      abyssResponse = 'Listening for your question...';
      notifyListeners();

      try {        await _speechToText.listen(
          onResult: (result) {
            recognizedWords = result.recognizedWords;
            if (recognizedWords.isNotEmpty) {
              spokenText = 'You said: "$recognizedWords"';
              // Don't auto-stop, let user control when to stop for longer questions
            } else {
              spokenText = 'Listening... Speak your question clearly';
            }
            notifyListeners();
          },
          listenFor: const Duration(seconds: 60), // Extended to 60 seconds for longer questions
          pauseFor: const Duration(seconds: 8), // Longer pause detection for thinking time
          localeId: 'en_US',
          listenOptions: SpeechListenOptions(
            partialResults: true,
            cancelOnError: false,
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
      isListening = false;
      
      if (recognizedWords.isNotEmpty) {
        _pendingVoiceQuestion = recognizedWords;
        _waitingForShake = true;
        _hasAskedQuestion = true;
        spokenText = 'Great! Now shake your phone to consult the abyss!';
        abyssResponse = 'Shake for your answer...';
      } else {
        spokenText = 'No speech detected. Try again.';
        _waitingForShake = false;
        abyssResponse = 'Ask your question...';
      }
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    if (isListening) {
      await _speechToText.stop();
      isListening = false;
      spokenText = '';
      recognizedWords = '';
      _pendingVoiceQuestion = '';
      _waitingForShake = false;
      _hasAskedQuestion = false;
      abyssResponse = 'Ask your question...';
      errorMessage = null;
      notifyListeners();
    }
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
    _hasAskedQuestion = false;
    isListening = false;
    _waitingForShake = false;
    _pendingVoiceQuestion = '';
    spokenText = '';
    recognizedWords = '';
    _speechToText.stop();
    notifyListeners();
  }
  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    _shakeDetector.dispose();
    _speechToText.stop();
    super.dispose();
  }
}
