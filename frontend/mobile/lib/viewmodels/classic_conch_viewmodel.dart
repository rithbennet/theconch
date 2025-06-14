import 'package:flutter/material.dart';
import 'package:theconch/services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class ClassicConchViewModel extends ChangeNotifier {
  bool isLoading = false;
  String conchResponse = '...';
  String? errorMessage;
  String? lastAudioUrl;
  bool isPlayingAudio = false;
  bool isListening = false;
  String spokenText = '';
  String recognizedWords = ''; // For debugging display
  final AudioPlayer audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  ClassicConchViewModel() {
    // Listen to player state changes
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlayingAudio = state == PlayerState.playing;
      notifyListeners();
    });

    // Initialize speech to text
    _initSpeech();
  }
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (errorNotification) {
        print('Speech recognition error: ${errorNotification.errorMsg}');

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
        print('Speech recognition status: $status');
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
    notifyListeners();
    try {
      final result = await ApiService.askClassicConch();
      conchResponse = result['answer'] ?? '...';
      lastAudioUrl = result['audioUrl'];
      if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty) {
        print('DEBUG: Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.stop();
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          print('DEBUG: Audio playback error: $audioError');
          errorMessage = 'Audio playback failed: $audioError';
        }
      } else {
        print('DEBUG: No audio URL provided');
      }
    } catch (e) {
      print('DEBUG: API call error: $e');
      conchResponse = 'Error!';
      errorMessage = e.toString();
    } finally {
      isLoading = false;
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
          partialResults: true,
          localeId: 'en_US',
          cancelOnError: false, // Don't cancel immediately on errors
          listenMode: ListenMode.confirmation,
        );
      } catch (e) {
        print('DEBUG: Speech listening error: $e');
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
        spokenText = 'Processing: "$recognizedWords"';
        notifyListeners();

        // Send the recognized text to the API
        await pullTheStringWithVoice(recognizedWords);
      } else {
        spokenText = 'No speech detected. Try again.';
        notifyListeners();
      }
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
        print('DEBUG: Attempting to play audio from $lastAudioUrl');
        try {
          await audioPlayer.stop();
          await audioPlayer.play(UrlSource(lastAudioUrl!));
        } catch (audioError) {
          print('DEBUG: Audio playback error: $audioError');
          errorMessage = 'Audio playback failed: $audioError';
        }
      } else {
        print('DEBUG: No audio URL provided');
      }
    } catch (e) {
      print('DEBUG: API call error: $e');
      conchResponse = 'Error!';
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      spokenText = '';
      notifyListeners();
    }
  }

  Future<void> playAudio() async {
    if (lastAudioUrl != null && lastAudioUrl!.isNotEmpty && !isPlayingAudio) {
      print('DEBUG: Playing audio from $lastAudioUrl');
      try {
        await audioPlayer.stop();
        await audioPlayer.play(UrlSource(lastAudioUrl!));
      } catch (audioError) {
        print('DEBUG: Audio playback error: $audioError');
        errorMessage = 'Audio playback failed: ${audioError.toString()}';
        notifyListeners();
      }
    }
  }

  // Reset speech recognition state
  void resetSpeechState() {
    isListening = false;
    spokenText = '';
    recognizedWords = '';
    errorMessage = null;
    _speechToText.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _speechToText.stop();
    super.dispose();
  }
}
