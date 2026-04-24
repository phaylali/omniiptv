import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/channel.dart';
import '../../providers/channel_provider.dart';
import '../../providers/overlay_provider.dart';

class ChannelListOverlay extends ConsumerWidget {
  const ChannelListOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = ref.watch(activeChannelsProvider);

    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[800],
            child: Row(
              children: [
                const Text(
                  'Channel List',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.read(showOverlayProvider.notifier).state = false;
                  },
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ChannelTile(channel: channel);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelTile extends ConsumerWidget {
  final Channel channel;

  const ChannelTile({super.key, required this.channel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChannel = ref.watch(currentChannelProvider);
    final isSelected = currentChannel?.id == channel.id;

    return GestureDetector(
      onTap: () {
        final channels = ref.read(activeChannelsProvider);
        final index = channels.indexOf(channel);
        if (index != -1) {
          ref.read(channelIndexProvider.notifier).state = index;
          ref.read(showOverlayProvider.notifier).state = false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(channel.icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              channel.name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
