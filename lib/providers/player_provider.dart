import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';

// Volume provider (0.0 - 1.0)
final volumeProvider = StateProvider<double>(
  (ref) => AppConstants.defaultVolume,
);

// Is playing provider (derived from player state, but we'll manage locally)
final isPlayingProvider = StateProvider<bool>((ref) => false);

// Current position provider
final currentPositionProvider = StateProvider<Duration>((ref) => Duration.zero);

// Buffered position provider
final bufferedPositionProvider = StateProvider<Duration>(
  (ref) => Duration.zero,
);

// Is fullscreen provider
final isFullScreenProvider = StateProvider<bool>((ref) => false);
