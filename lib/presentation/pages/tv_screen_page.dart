import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/shortcuts.dart' as app_shortcuts;
import '../../providers/channel_provider.dart';
import '../../providers/overlay_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/overlay_column.dart';
import '../widgets/channel_notification.dart';
import '../widgets/settings_overlay.dart';
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

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final channels = ref.read(channelsByOrderProvider);
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
          ref.read(showOverlayProvider.notifier).state = false;
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
          ref.read(showOverlayProvider.notifier).state = false;
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
          ref.read(showOverlayProvider.notifier).state = false;
          break;
        case app_shortcuts.AppShortcuts.toggleFullscreen:
          if (Platform.isLinux) {
            final current = ref.read(isFullScreenProvider);
            final newState = !current;
            ref.read(isFullScreenProvider.notifier).state = newState;
            windowManager.setFullScreen(newState);
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showOverlay = ref.watch(showOverlayProvider);
    final overlayType = ref.watch(overlayTypeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            // Video player at base
            const VideoPlayerWidget(),
            // Top channel notification
            const ChannelNotification(),
            // Right-side overlay
            const OverlayColumn(),
            // Conditional overlays
            if (showOverlay && overlayType == OverlayType.settings)
              const SettingsOverlay(),
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
}
