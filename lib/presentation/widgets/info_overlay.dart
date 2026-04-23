import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/channel_provider.dart';
import '../../providers/overlay_provider.dart';

class InfoOverlay extends ConsumerWidget {
  const InfoOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(currentChannelProvider);

    if (channel == null) {
      return Container(
        color: Colors.black.withOpacity(0.8),
        child: const Center(
          child: Text(
            'No channel selected',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(channel.icon, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              channel.name,
              style: const TextStyle(color: Colors.white, fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              'Order: ${channel.order}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (channel.country != null)
              Text(
                'Country: ${channel.country}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            if (channel.category != null)
              Text(
                'Category: ${channel.category}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(showOverlayProvider.notifier).state = false;
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
