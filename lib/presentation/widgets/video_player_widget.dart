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
    ref.listen<Channel?>(currentChannelProvider, (previous, next) {
      if (next != null && next != previous) {
        _initializePlayer(next);
      }
    });
    // Listen for volume changes
    ref.listen<double>(volumeProvider, (previous, next) {
      if (previous != next) {
        _player?.setVolume(next * 100); // media_kit uses 0-100
      }
    });
  }

  Future<void> _initializePlayer(Channel channel) async {
    // Dispose previous player
    await _player?.dispose();
    _player = Player();
    _controller = VideoController(_player!);
    _errorMessage = '';

    // Try each stream URL until one works
    for (final streamUrl in channel.streamUrls) {
      try {
        Map<String, String> headers = {};
        final url = streamUrl.url;
        if (url.contains('livemediama.com')) {
          headers['Referer'] = 'https://livemediama.com/';
          headers['User-Agent'] =
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
        } else if (url.contains('globecast') || url.contains('snrt')) {
          headers['Referer'] = 'https://www.snrt.ma/';
          headers['User-Agent'] =
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
        } else if (url.contains('tvanywhere.ae')) {
          headers['User-Agent'] =
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
        }

        final media = Media(url, httpHeaders: headers);
        await _player!.open(media, play: true);
        // Set initial volume
        final volume = ref.read(volumeProvider);
        await _player!.setVolume(volume * 100);
        setState(() {
          _errorMessage = '';
        });
        break; // Success, stop trying
      } catch (e) {
        // Dispose current player and try next
        await _player?.dispose();
        _player = null;
        _controller = null;
        // Continue to next URL
      }
    }

    // If all URLs failed
    if (_player == null) {
      setState(() {
        _errorMessage = 'Failed to load any stream for ${channel.name}';
      });
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
