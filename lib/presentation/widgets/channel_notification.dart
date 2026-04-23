import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/channel_provider.dart';

class ChannelNotification extends ConsumerStatefulWidget {
  const ChannelNotification({super.key});

  @override
  ConsumerState<ChannelNotification> createState() =>
      _ChannelNotificationState();
}

class _ChannelNotificationState extends ConsumerState<ChannelNotification>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController!, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _showNotification() {
    if (_isVisible) return;
    _isVisible = true;
    _animationController?.forward();

    // Auto-hide after 5 seconds
    Future.delayed(AppConstants.overlayAutoHideDuration, () {
      if (mounted) {
        _hideNotification();
      }
    });
  }

  void _hideNotification() {
    if (!_isVisible) return;
    _isVisible = false;
    _animationController?.reverse();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentChannelProvider, (previous, next) {
      if (next != null && next != previous) {
        _showNotification();
      }
    });

    final channel = ref.watch(currentChannelProvider);
    if (channel == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _slideAnimation!,
      builder: (context, child) {
        return SlideTransition(position: _slideAnimation!, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.black.withOpacity(0.8),
        child: Row(
          children: [
            Text(
              '${channel.order.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                channel.name,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Icon(channel.icon, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }
}
