import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../core/constants/app_constants.dart';

// Volume provider
final volumeProvider = StateProvider<double>(
  (ref) => AppConstants.defaultVolume,
);

// Is playing provider
final isPlayingProvider = StateProvider<bool>((ref) => false);

// Current position provider
final currentPositionProvider = StateProvider<Duration>((ref) => Duration.zero);

// Buffered position provider
final bufferedPositionProvider = StateProvider<Duration>(
  (ref) => Duration.zero,
);

// Is fullscreen provider
final isFullScreenProvider = StateProvider<bool>((ref) => false);

// Video player controller provider
final videoPlayerControllerProvider = Provider<VideoPlayerController?>((ref) {
  // This will be initialized when a channel is selected
  // For now, return null
  return null;
});
