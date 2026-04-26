import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
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
      if (mounted) {
        ref.read(showOverlayProvider.notifier).state = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual<bool>(showOverlayProvider, (previous, isVisible) {
      if (isVisible) {
        _resetHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
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
        width: 100,
        color: Colors.black.withOpacity(AppConstants.overlayOpacity),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NavButton(
              autofocus: true,
              icon: TablerIcons.settings,
              label: 'SETTINGS',
              onPressed: () {
                ref.read(showOverlayProvider.notifier).state = false;
                GoRouter.of(context).push('/settings');
              },
              onFocused: _resetHideTimer,
            ),
            SizedBox(height: AppConstants.iconSpacing),
            _NavButton(
              icon: TablerIcons.list,
              label: 'CHANNELS',
              onPressed: () {
                ref.read(overlayTypeProvider.notifier).state =
                    OverlayType.channelList;
                _resetHideTimer();
              },
              onFocused: _resetHideTimer,
            ),
            SizedBox(height: AppConstants.iconSpacing),
            _NavButton(
              icon: TablerIcons.info_circle,
              label: 'INFO',
              onPressed: () {
                ref.read(overlayTypeProvider.notifier).state = OverlayType.info;
                _resetHideTimer();
              },
              onFocused: _resetHideTimer,
            ),
            SizedBox(height: AppConstants.iconSpacing),
            _NavButton(
              icon: TablerIcons.volume,
              label: 'VOLUME',
              onPressed: () {
                ref.read(overlayTypeProvider.notifier).state =
                    OverlayType.volume;
                _resetHideTimer();
              },
              onFocused: _resetHideTimer,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String label;
  final bool autofocus;
  final VoidCallback onFocused;

  const _NavButton({
    required this.icon,
    required this.onPressed,
    required this.label,
    required this.onFocused,
    this.autofocus = false,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
        if (hasFocus) widget.onFocused();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _isFocused
                    ? Colors.blue.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isFocused ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  widget.icon,
                  color: _isFocused ? Colors.blue : Colors.white,
                ),
                iconSize: AppConstants.iconSize * 1.2,
                onPressed: widget.onPressed,
              ),
            ),
            if (_isFocused)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
