import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../subscription/services/analytics_service.dart';

/// Full-screen guided-video tool session (Workout, Meditation, Stretch, Wim Hof).
///
/// Plays a looping remote video. Tapping toggles the control overlay (mute,
/// title, close, play/pause, scrub bar), which auto-hides after 3s of playback
/// so the video can be watched unobstructed. Closing (X) pops back to Tools.
class VideoToolSessionScreen extends StatefulWidget {
  final String title;
  final String videoUrl;

  const VideoToolSessionScreen({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<VideoToolSessionScreen> createState() => _VideoToolSessionScreenState();
}

class _VideoToolSessionScreenState extends State<VideoToolSessionScreen> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _error = false;
  bool _muted = false;
  bool _finished = false;

  // Control-overlay visibility with a 3s auto-hide (only while playing).
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Allow landscape so the video can adapt to the phone's orientation.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    AnalyticsService.capture(
      AnalyticsService.toolSessionStarted,
      {'tool': widget.title},
    );
    _start();
  }

  Future<void> _start() async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      _controller = controller;
      // Rebuild on every position/state change to drive the scrub bar.
      controller.addListener(_onControllerUpdate);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(_muted ? 0 : 1);
      await controller.play();
      if (mounted) setState(() => _initialized = true);
      _scheduleHide();
    } catch (e) {
      debugPrint('[VideoToolSession] failed to load ${widget.title}: $e');
      if (mounted) setState(() => _error = true);
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    // The controller surfaces load failures via value.hasError too.
    if (_controller?.value.hasError ?? false) {
      if (!_error) setState(() => _error = true);
      return;
    }
    setState(() {});
  }

  /// Reveals the overlay and (re)arms the 3s auto-hide while playing.
  void _showControls() {
    setState(() => _controlsVisible = true);
    _scheduleHide();
  }

  /// Auto-hides the overlay after 3s — but only while the video is playing,
  /// so a paused video keeps its controls up.
  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_controller?.value.isPlaying ?? false) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
  }

  /// Tap on the video: show the overlay if hidden, hide it if shown.
  void _toggleControls() {
    HapticFeedback.selectionClick();
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null || !_initialized) return;
    HapticFeedback.selectionClick();
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    _showControls();
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    HapticFeedback.selectionClick();
    final next = !_muted;
    await controller.setVolume(next ? 0 : 1);
    if (mounted) setState(() => _muted = next);
    _scheduleHide();
  }

  Future<void> _seekTo(double ms) async {
    await _controller?.seekTo(Duration(milliseconds: ms.round()));
    _scheduleHide();
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    await _controller?.pause();
    HapticFeedback.mediumImpact();
    AnalyticsService.capture(
      AnalyticsService.toolSessionCompleted,
      {'tool': widget.title},
    );
    // Pop with `true` so the caller (e.g. chat) knows the session completed.
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _retry() async {
    _controller?.removeListener(_onControllerUpdate);
    await _controller?.dispose();
    _controller = null;
    setState(() {
      _error = false;
      _initialized = false;
    });
    await _start();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    // Restore portrait for the rest of the app.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = _controller;
    final value = controller?.value;
    final position = value?.position ?? Duration.zero;
    final total = value?.duration ?? Duration.zero;
    final totalMs = total.inMilliseconds.toDouble();
    final playing = value?.isPlaying ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full video shown uncropped (letterboxed), tap toggles the overlay.
          if (_initialized && controller != null && !_error)
            GestureDetector(
              onTap: _toggleControls,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            )
          else if (_error)
            GestureDetector(
              onTap: _retry,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 40.sp, color: Colors.white70),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.toolSessionLoadError,
                      style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Control overlay: scrim + top bar + center play/pause + scrub bar.
          // Fades out after 3s of playback and ignores taps while hidden.
          AnimatedOpacity(
            opacity: _controlsVisible ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Legibility scrim (taps pass through to the video below).
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(140),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withAlpha(160),
                          ],
                          stops: const [0.0, 0.25, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Center play/pause toggle.
                  if (_initialized && !_error)
                    Center(
                      child: GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 76.w,
                          height: 76.w,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            size: 44.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  SafeArea(
                    child: Column(
                      children: [
                        // Top bar: mute (left), title (center), close (right).
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          child: Row(
                            children: [
                              _circleButton(
                                icon: _muted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                onTap: _toggleMute,
                              ),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              _circleButton(
                                  icon: Icons.close, onTap: _finish),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Bottom controls: scrub bar + time readout.
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4.h,
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white24,
                                ),
                                child: Slider(
                                  value: position.inMilliseconds
                                      .toDouble()
                                      .clamp(0.0, totalMs > 0 ? totalMs : 1.0),
                                  max: totalMs > 0 ? totalMs : 1.0,
                                  onChanged: totalMs > 0 ? _seekTo : null,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _fmt(position),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white70,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _fmt(total),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white70,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Small translucent circular icon button used in the top bar.
  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22.sp, color: Colors.white),
      ),
    );
  }
}
