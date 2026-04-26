import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/shortcuts.dart' as app_shortcuts;
import '../../data/models/channel.dart';
import '../../providers/channel_provider.dart';
import '../../providers/overlay_provider.dart';
import '../../providers/player_provider.dart';
import '../../core/utils/storage_service.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/overlay_column.dart';
import '../widgets/channel_notification.dart';
import '../widgets/channel_list_overlay.dart';
import '../widgets/info_overlay.dart';
import '../widgets/volume_overlay.dart';

class TvScreenPage extends ConsumerStatefulWidget {
  const TvScreenPage({super.key});

  @override
  ConsumerState<TvScreenPage> createState() => _TvScreenPageState();
}

class _TvScreenPageState extends ConsumerState<TvScreenPage> {
  final FocusNode _focusNode = FocusNode();
  final bool _listenersAdded = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    // Persistence listeners
    ref.listenManual<double>(volumeProvider, (previous, next) {
      if (previous != next) {
        StorageService.saveVolume(next);
      }
    });

    ref.listenManual<Channel?>(currentChannelProvider, (previous, next) {
      if (next != null) {
        StorageService.saveCurrentChannelId(next.id);
      }
    });

    // Initial loads
    Future.microtask(() async {
      final savedVolume = await StorageService.loadVolume();
      if (mounted) {
        ref.read(volumeProvider.notifier).state = savedVolume;
      }
    });

    Future.microtask(() async {
      // Need to wait for the provider to be ready
      final channels = await ref.read(channelListProvider.future);
      if (mounted && channels.channels.isNotEmpty) {
        final savedChannelId = await StorageService.loadCurrentChannelId();
        if (savedChannelId != null) {
          final index = channels.channels.indexWhere(
            (c) => c.id == savedChannelId,
          );
          if (index != -1) {
            ref.read(channelIndexProvider.notifier).state = index;
            return;
          }
        }
        ref.read(channelIndexProvider.notifier).state = 0;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showOverlay = ref.watch(showOverlayProvider);
    final overlayType = ref.watch(overlayTypeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            const VideoPlayerWidget(),
            const ChannelNotification(),
            const OverlayColumn(),
            if (showOverlay && overlayType == OverlayType.channelList)
              const ChannelListOverlay(),
            if (showOverlay && overlayType == OverlayType.info)
              const InfoOverlay(),
            if (showOverlay && overlayType == OverlayType.volume)
              const VolumeOverlay(),
          ],
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final channels = ref.read(activeChannelsProvider);
      final currentIndex = ref.read(channelIndexProvider);

      switch (event.logicalKey) {
        case app_shortcuts.AppShortcuts.channelUp:
          if (channels.isNotEmpty) {
            final newIndex =
                (currentIndex - 1 + channels.length) % channels.length;
            ref.read(channelIndexProvider.notifier).state = newIndex;
          }
          break;
        case app_shortcuts.AppShortcuts.channelDown:
          if (channels.isNotEmpty) {
            final newIndex = (currentIndex + 1) % channels.length;
            ref.read(channelIndexProvider.notifier).state = newIndex;
          }
          break;
        case app_shortcuts.AppShortcuts.volumeUp:
          final currentVolume = ref.read(volumeProvider);
          ref.read(volumeProvider.notifier).state = (currentVolume + 0.1).clamp(
            0.0,
            1.0,
          );
          break;
        case app_shortcuts.AppShortcuts.volumeDown:
          final currentVolume = ref.read(volumeProvider);
          ref.read(volumeProvider.notifier).state = (currentVolume - 0.1).clamp(
            0.0,
            1.0,
          );
          break;
        case app_shortcuts.AppShortcuts.showOverlay:
          final showOverlay = ref.read(showOverlayProvider);
          ref.read(showOverlayProvider.notifier).state = !showOverlay;
          break;
        case app_shortcuts.AppShortcuts.hideOverlay:
          final showOverlay = ref.read(showOverlayProvider);
          if (showOverlay) {
            ref.read(showOverlayProvider.notifier).state = false;
          } else {
            Navigator.pop(context);
          }
          break;
        case app_shortcuts.AppShortcuts.toggleFullscreen:
          if (Platform.isLinux) {
            final current = ref.read(isFullScreenProvider);
            final newState = !current;
            ref.read(isFullScreenProvider.notifier).state = newState;
            windowManager.setFullScreen(newState);
          }
          break;
        case LogicalKeyboardKey.escape:
          final showOverlay = ref.read(showOverlayProvider);
          if (showOverlay) {
            ref.read(showOverlayProvider.notifier).state = false;
          }
          break;
      }
    }
  }
}
