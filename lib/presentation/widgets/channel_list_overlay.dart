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
            color: Colors.grey[900],
            child: Row(
              children: [
                const Text(
                  'Channel List',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                  child: ChannelTile(channel: channel, autofocus: index == 0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelTile extends ConsumerStatefulWidget {
  final Channel channel;
  final bool autofocus;

  const ChannelTile({super.key, required this.channel, this.autofocus = false});

  @override
  ConsumerState<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends ConsumerState<ChannelTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final currentChannel = ref.watch(currentChannelProvider);
    final isPlaying = currentChannel?.id == widget.channel.id;

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: GestureDetector(
        onTap: () {
          final channels = ref.read(activeChannelsProvider);
          final index = channels.indexOf(widget.channel);
          if (index != -1) {
            ref.read(channelIndexProvider.notifier).state = index;
            ref.read(showOverlayProvider.notifier).state = false;
          }
        },
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: _isFocused 
              ? Colors.blue.withValues(alpha: 0.4) 
              : isPlaying 
                ? Colors.blue.withValues(alpha: 0.1) 
                : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? Colors.blue : isPlaying ? Colors.blue.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
              width: _isFocused ? 3 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.channel.logoUrl != null
                        ? Image.network(
                            widget.channel.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(widget.channel.icon, color: Colors.white, size: 30),
                          )
                        : Icon(widget.channel.icon, color: Colors.white, size: 30),
                  ),
                  Positioned(
                    top: -5,
                    left: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        widget.channel.order.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.channel.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: _isFocused || isPlaying ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      widget.channel.category ?? 'General',
                      style: TextStyle(
                        color: _isFocused ? Colors.white : Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPlaying)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.play_circle_fill, color: Colors.blue, size: 36),
                ),
              if (_isFocused && !isPlaying)
                 const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
