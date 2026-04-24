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
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ChannelTile(channel: channel),
                );
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
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.3) : Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            SizedBox(
              width: 60,
              height: 60,
              child: channel.logoUrl != null
                  ? Image.network(
                      channel.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(channel.icon, color: Colors.white, size: 30),
                    )
                  : Icon(channel.icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    channel.category ?? 'General',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.play_circle_fill, color: Colors.blue, size: 32),
              ),
          ],
        ),
      ),
    );
  }
}
