import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/overlay_provider.dart';

class OverlayColumn extends ConsumerStatefulWidget {
  const OverlayColumn({super.key});

  @override
  ConsumerState<OverlayColumn> createState() => _OverlayColumnState();
}

class _OverlayColumnState extends ConsumerState<OverlayColumn> {
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(AppConstants.overlayAutoHideDuration, () {
      ref.read(showOverlayProvider.notifier).state = false;
    });
  }

  void _showOverlay(OverlayType type) {
    ref.read(showOverlayProvider.notifier).state = true;
    ref.read(overlayTypeProvider.notifier).state = type;
    _resetHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final showOverlay = ref.watch(showOverlayProvider);

    if (!showOverlay) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 80,
        color: Colors.black.withOpacity(AppConstants.overlayOpacity),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(TablerIcons.settings, color: Colors.white),
              iconSize: AppConstants.iconSize,
              onPressed: () => _showOverlay(OverlayType.settings),
            ),
            SizedBox(height: AppConstants.iconSpacing),
            IconButton(
              icon: const Icon(TablerIcons.list, color: Colors.white),
              iconSize: AppConstants.iconSize,
              onPressed: () => _showOverlay(OverlayType.channelList),
            ),
            SizedBox(height: AppConstants.iconSpacing),
            IconButton(
              icon: const Icon(TablerIcons.info_circle, color: Colors.white),
              iconSize: AppConstants.iconSize,
              onPressed: () => _showOverlay(OverlayType.info),
            ),
            SizedBox(height: AppConstants.iconSpacing),
            IconButton(
              icon: const Icon(TablerIcons.volume, color: Colors.white),
              iconSize: AppConstants.iconSize,
              onPressed: () => _showOverlay(OverlayType.volume),
            ),
          ],
        ),
      ),
    );
  }
}
