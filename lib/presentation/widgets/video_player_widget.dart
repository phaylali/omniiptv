import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../providers/channel_provider.dart';
import '../../providers/player_provider.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializePlayer());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    final channel = ref.read(currentChannelProvider);
    if (channel != null && channel.streamUrls.isNotEmpty) {
      for (final streamUrl in channel.streamUrls) {
        try {
          // Add headers for known streams that require them
          Map<String, String> headers = {};
          if (streamUrl.url.contains('livemediama.com')) {
            headers['Referer'] = 'https://livemediama.com/';
            headers['User-Agent'] =
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
          } else if (streamUrl.url.contains('globecast') ||
              streamUrl.url.contains('snrt')) {
            headers['Referer'] = 'https://www.snrt.ma/';
            headers['User-Agent'] =
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
          } else if (streamUrl.url.contains('tvanywhere.ae')) {
            headers['User-Agent'] =
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
          }

          _controller = VideoPlayerController.networkUrl(
            Uri.parse(streamUrl.url),
            httpHeaders: headers,
          );
          await _controller!.initialize().timeout(const Duration(seconds: 30));
          setState(() {
            _errorMessage = '';
          });
          _controller?.play();
          ref.read(isPlayingProvider.notifier).state = true;
          // Set initial volume
          final volume = ref.read(volumeProvider);
          _controller?.setVolume(volume);
          break; // Success, stop trying
        } catch (e) {
          _controller?.dispose();
          _controller = null;
          setState(() {
            _errorMessage = 'Failed to load stream: $e';
          });
          // Try next URL
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentChannelProvider, (previous, next) {
      if (next != null && next != previous) {
        _controller?.dispose();
        _initializePlayer();
      }
    });

    ref.listen(volumeProvider, (previous, next) {
      _controller?.setVolume(next);
    });

    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
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
