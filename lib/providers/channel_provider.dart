import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/channel_repository.dart';
import '../data/models/channel.dart';
import '../data/models/channel_list.dart';

// Repository provider
final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  return ChannelRepository();
});

// All channels provider (including inactive)
final allChannelsProvider = FutureProvider<ChannelList>((ref) async {
  final repository = ref.watch(channelRepositoryProvider);
  return await repository.loadAllChannels();
});

// Channel list provider (active channels only)
final channelListProvider = FutureProvider<ChannelList>((ref) async {
  final repository = ref.watch(channelRepositoryProvider);
  return await repository.loadChannels();
});

// Current channel index provider
final channelIndexProvider = StateProvider<int>((ref) => 0);

// Active channels provider
final activeChannelsProvider = Provider<List<Channel>>((ref) {
  final channelListAsync = ref.watch(channelListProvider);
  return channelListAsync.maybeWhen(
    data: (channelList) => channelList.channels,
    orElse: () => [],
  );
});

// Current channel provider
final currentChannelProvider = Provider<Channel?>((ref) {
  final channels = ref.watch(activeChannelsProvider);
  final index = ref.watch(channelIndexProvider);
  if (channels.isEmpty || index < 0 || index >= channels.length) {
    return null;
  }
  return channels[index];
});
