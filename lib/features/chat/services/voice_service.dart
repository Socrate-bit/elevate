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

  // Continuous-dictation state. The platform speech recognizer auto-stops on
  // silence and after a max session length; to keep the mic open until the user
  // stops it (like Claude), we transparently restart it while [_keepAlive].
  bool _keepAlive = false; // true while the user still wants to dictate
  bool _restarting = false; // guards against overlapping restarts
  String _committed = ''; // transcript accepted from prior (restarted) sessions
  String _lastLive = ''; // most recent full transcript pushed to the UI
  void Function(String transcript)? _onPartial;

  @override
  bool get isAvailable => _initOk;

  // Report listening while we intend to keep the mic alive, even during the
  // brief gaps when the platform recognizer is being restarted.
  @override
  bool get isListening => _keepAlive || _stt.isListening;

  @override
  Future<bool> initialize() async {
    if (_initAttempted) return _initOk;
    _initAttempted = true;
    try {
      _initOk = await _stt.initialize(
        onError: (e) {
          debugPrint('[VoiceService] error: ${e.errorMsg}');
          // Recoverable errors end the session; restart if still wanted.
          _maybeRestart();
        },
        onStatus: (s) {
          debugPrint('[VoiceService] status: $s');
          // Platform ended the session (silence/timeout) — keep it going.
          if (s == 'done' || s == 'notListening') _maybeRestart();
        },
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
    _onPartial = onPartial;
    _keepAlive = true;
    _committed = '';
    _lastLive = '';
    await _listen();
  }

  /// Starts one recognizer session. Partials are folded onto the transcript
  /// committed from previous sessions so restarts are seamless to the user.
  Future<void> _listen() async {
    try {
      await _stt.listen(
        onResult: (r) {
          final words = r.recognizedWords;
          _lastLive = _committed.isEmpty
              ? words
              : (words.isEmpty ? _committed : '$_committed $words');
          _onPartial?.call(_lastLive);
        },
        // Long windows so the platform rarely ends a session on its own; when
        // it does, [_maybeRestart] brings it back until the user stops.
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(minutes: 5),
        ),
      );
    } catch (e) {
      debugPrint('[VoiceService] listen failed: $e');
      rethrow;
    }
  }

  /// Restarts the recognizer after the platform ended a session, preserving the
  /// text captured so far. No-op once the user has stopped dictation.
  Future<void> _maybeRestart() async {
    if (!_keepAlive || _restarting || _stt.isListening) return;
    _restarting = true;
    // Commit what we have so the next session appends rather than overwrites.
    _committed = _lastLive;
    // Small delay lets the platform fully tear down before we re-arm it,
    // avoiding a tight restart loop.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!_keepAlive) {
      _restarting = false;
      return;
    }
    try {
      await _listen();
    } catch (e) {
      debugPrint('[VoiceService] restart failed: $e');
    } finally {
      _restarting = false;
    }
  }

  @override
  Future<void> stop() async {
    _keepAlive = false; // stop first so status callbacks don't restart us
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
