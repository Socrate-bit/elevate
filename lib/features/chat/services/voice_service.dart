import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Voice capture surface for the chat composer. Implementations:
/// [VoiceService] (real, speech_to_text) or a fake for tests.
abstract interface class VoiceController {
  bool get isAvailable;
  bool get isListening;

  /// Returns true if the platform is ready to capture audio.
  Future<bool> initialize();

  /// Starts listening; [onPartial] receives the running transcript.
  Future<void> start({required void Function(String transcript) onPartial});

  /// Stops listening (idempotent).
  Future<void> stop();
}

/// Real implementation backed by [SpeechToText].
class VoiceService implements VoiceController {
  VoiceService();

  /// Default singleton used by production code.
  static final VoiceController instance = VoiceService();

  final SpeechToText _stt = SpeechToText();
  bool _initAttempted = false;
  bool _initOk = false;

  @override
  bool get isAvailable => _initOk;

  @override
  bool get isListening => _stt.isListening;

  @override
  Future<bool> initialize() async {
    if (_initAttempted) return _initOk;
    _initAttempted = true;
    try {
      _initOk = await _stt.initialize(
        onError: (e) => debugPrint('[VoiceService] error: ${e.errorMsg}'),
        onStatus: (s) => debugPrint('[VoiceService] status: $s'),
      );
      debugPrint('[VoiceService] initialize → $_initOk');
    } catch (e) {
      debugPrint('[VoiceService] initialize failed: $e');
      _initOk = false;
    }
    return _initOk;
  }

  @override
  Future<void> start({
    required void Function(String transcript) onPartial,
  }) async {
    if (!_initOk) {
      final ok = await initialize();
      if (!ok) throw const VoiceUnavailableException();
    }
    try {
      await _stt.listen(
        onResult: (r) => onPartial(r.recognizedWords),
        listenOptions: SpeechListenOptions(partialResults: true),
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(minutes: 1),
      );
    } catch (e) {
      debugPrint('[VoiceService] start failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (e) {
      debugPrint('[VoiceService] stop failed: $e');
    }
  }
}

class VoiceUnavailableException implements Exception {
  const VoiceUnavailableException();
}
