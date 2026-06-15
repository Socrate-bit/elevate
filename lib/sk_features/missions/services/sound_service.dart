import 'package:flutter/services.dart';

/// Provides audio cues for mission rep completion.
/// Currently uses haptic feedback as a stand-in — swap out for a real
/// audio package (e.g. audioplayers) when sound assets are available.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  Future<void> playRepBell() async {
    await HapticFeedback.heavyImpact();
  }
}
