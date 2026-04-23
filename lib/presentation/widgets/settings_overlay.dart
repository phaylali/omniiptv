import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/channel.dart';
import '../../data/models/channel_list.dart';
import '../../providers/channel_provider.dart';
import '../../providers/overlay_provider.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/services/iptv_fetcher.dart';

class SettingsOverlay extends ConsumerStatefulWidget {
  const SettingsOverlay({super.key});

  @override
  ConsumerState<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends ConsumerState<SettingsOverlay> {
  late List<Channel> _channels;

  @override
  void initState() {
    super.initState();
    final channelListAsync = ref.read(channelListProvider);
    channelListAsync.whenData((channelList) {
      _channels = List.from(channelList.channels);
    });
  }

  void _toggleChannel(Channel channel) {
    setState(() {
      final index = _channels.indexOf(channel);
      if (index != -1) {
        _channels[index] = Channel(
          id: channel.id,
          name: channel.name,
          iconName: channel.iconName,
          streamUrls: channel.streamUrls,
          country: channel.country,
          category: channel.category,
          order: channel.order,
          isActive: !channel.isActive,
        );
      }
    });
    _saveChanges();
  }

  void _reorderChannels(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _channels.removeAt(oldIndex);
      _channels.insert(newIndex, item);
      // Update orders
      for (int i = 0; i < _channels.length; i++) {
        _channels[i] = Channel(
          id: _channels[i].id,
          name: _channels[i].name,
          iconName: _channels[i].iconName,
          streamUrls: _channels[i].streamUrls,
          country: _channels[i].country,
          category: _channels[i].category,
          order: i + 1,
          isActive: _channels[i].isActive,
        );
      }
    });
    _saveChanges();
  }

  void _saveChanges() async {
    final repository = ref.read(channelRepositoryProvider);
    final channelListAsync = ref.read(channelListProvider);
    channelListAsync.whenData((channelList) async {
      final updatedList = ChannelList(
        version: channelList.version,
        channels: _channels,
        lastUpdated: DateTime.now(),
        source: channelList.source,
      );
      await repository.saveChannelList(updatedList);
      // Refresh providers if needed
      ref.invalidate(channelListProvider);
    });
  }

  void _updateChannels() async {
    final fetcher = IptvFetcher();
    final fetchedChannels = await fetcher.fetchMoroccanChannels();
    if (fetchedChannels.isNotEmpty) {
      setState(() {
        _channels = fetchedChannels;
      });
      _saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelListAsync = ref.watch(channelListProvider);

    return channelListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (channelList) {
        if (_channels.isEmpty) {
          _channels = List.from(channelList.channels);
        }

        return Container(
          color: Colors.black.withOpacity(0.9),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[800],
                child: Row(
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _updateChannels,
                      child: const Text('Update Channels'),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        ref.read(showOverlayProvider.notifier).state = false;
                      },
                    ),
                  ],
                ),
              ),
              // Channel list
              Expanded(
                child: ReorderableListView(
                  onReorder: _reorderChannels,
                  children: _channels.map((channel) {
                    return ListTile(
                      key: ValueKey(channel.id),
                      leading: Icon(channel.icon, color: Colors.white),
                      title: Text(
                        channel.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: channel.isActive,
                            onChanged: (value) => _toggleChannel(channel),
                          ),
                          const Icon(Icons.drag_handle, color: Colors.white),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
