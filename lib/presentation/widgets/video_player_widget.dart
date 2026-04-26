import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../providers/channel_provider.dart';
import '../../providers/player_provider.dart';
import '../../data/models/channel.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  Player? _player;
  VideoController? _controller;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Listen for channel changes
    ref.listenManual<Channel?>(currentChannelProvider, (previous, next) {
      if (next != null && next != previous) {
        _initializePlayer(next);
      }
    });
    // Listen for volume changes
    ref.listenManual<double>(volumeProvider, (previous, next) {
      if (previous != next) {
        _player?.setVolume(next * 100); // media_kit uses 0-100
      }
    });

    // Initial play if channel already selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialChannel = ref.read(currentChannelProvider);
      if (initialChannel != null) {
        _initializePlayer(initialChannel);
      }
    });
  }

  bool _isInitializing = false;

  Future<void> _initializePlayer(Channel channel) async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      // Dispose previous player
      final oldPlayer = _player;
      _player = null;
      _controller = null;
      await oldPlayer?.dispose();

      // Create new player with performance-focused configuration
      _player = Player(
        configuration: const PlayerConfiguration(
          vo: 'gpu', // Switched from 'gpu-next' to 'gpu' for lower overhead
        ),
      );

      // Performance optimizations to lower CPU usage
      if (_player!.platform is NativePlayer) {
        final mpv = _player!.platform as NativePlayer;
        await mpv.setProperty('profile', 'low-latency');
        await mpv.setProperty('hwdec', 'auto-safe');
        await mpv.setProperty('vd-lavc-threads', '4'); 
        await mpv.setProperty('cache', 'yes');
        await mpv.setProperty('demuxer-max-bytes', '50M');
        await mpv.setProperty('demuxer-max-back-bytes', '10M');
        
        // Fast decoding & Skip loop filter (saves a lot of CPU)
        await mpv.setProperty('vd-lavc-fast', 'yes');
        await mpv.setProperty('vd-lavc-skiploopfilter', 'all'); 
        await mpv.setProperty('hls-bitrate', 'min'); 

        // Disable CPU-heavy post-processing
        await mpv.setProperty('video-sync', 'audio'); 
        await mpv.setProperty('interpolation', 'no'); 
        await mpv.setProperty('deinterlace', 'no');   
        await mpv.setProperty('scale', 'bilinear');   
      }

      _controller = VideoController(
        _player!,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: true,
        ),
      );
      
      _errorMessage = '';
      setState(() {}); 

    // Try each stream URL until one works
    for (final streamUrl in channel.streamUrls) {
      try {
        Map<String, String> headers = {};
        final url = streamUrl.url;
        // ... (headers logic remains same)
        if (url.contains('livemediama.com')) {
          headers['Referer'] = 'https://livemediama.com/';
          headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
        } else if (url.contains('globecast') || url.contains('snrt')) {
          headers['Referer'] = 'https://www.snrt.ma/';
          headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
        }

        final media = Media(url, httpHeaders: headers);
        
        // Ultra-strict resolution and bitrate limiting
        if (_player!.platform is NativePlayer) {
          final mpv = _player!.platform as NativePlayer;
          if (streamUrl.quality > 0 && streamUrl.quality <= 480) {
            // Force 360p for SD channels
            await mpv.setProperty('ytdl-format', 'bestvideo[height<=360]+bestaudio/best[height<=360]');
            await mpv.setProperty('hls-cap-resolution', '640x360');
          } else {
            // Cap HD at 576p (Standard HD) for better performance
            await mpv.setProperty('ytdl-format', 'bestvideo[height<=576]+bestaudio/best[height<=576]');
            await mpv.setProperty('hls-cap-resolution', '1024x576');
          }
        }

        await _player!.open(media, play: true);
        // Set initial volume
        final volume = ref.read(volumeProvider);
        await _player!.setVolume(volume * 100);
        setState(() {
          _errorMessage = '';
        });
        break; // Success, stop trying
      } catch (e) {
        // Continue to next URL
      }
    }

    // If all URLs failed
    if (_player == null || !(_player!.state.playing)) {
      setState(() {
        _errorMessage = 'Failed to load any stream for ${channel.name}';
      });
    }
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    _player = null;
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      return SizedBox.expand(
        child: Video(controller: _controller!, fit: BoxFit.contain),
      );
    } else if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }
}
