import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class PlayerService {
  static Future<void> init() async {
    if (kIsWeb) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.movie,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    await session.setActive(true);
  }

  /// Global MPV properties that should be set on every player instance
  /// for maximum performance on Linux/TV.
  static Future<void> applyPerformanceFlags(Player player) async {
    if (player.platform is NativePlayer) {
      final mpv = player.platform as NativePlayer;
      
      // Essential for Linux H/W Acceleration
      await mpv.setProperty('hwdec', 'auto');
      await mpv.setProperty('vo', 'gpu');
      await mpv.setProperty('gpu-context', 'auto');
      
      // Latency and Threading
      await mpv.setProperty('profile', 'low-latency');
      await mpv.setProperty('vd-lavc-threads', '0'); // Auto-threads for multi-core S/W fallback
      await mpv.setProperty('vd-lavc-fast', 'yes');
      await mpv.setProperty('vd-lavc-skiploopfilter', 'all');
      
      // Buffering (Balanced for live)
      await mpv.setProperty('cache', 'yes');
      await mpv.setProperty('demuxer-max-bytes', '64M');
      await mpv.setProperty('demuxer-readahead-secs', '1');
      
      // Disable heavy post-processing
      await mpv.setProperty('video-sync', 'audio');
      await mpv.setProperty('interpolation', 'no');
      await mpv.setProperty('deinterlace', 'no');
    }
  }
}
