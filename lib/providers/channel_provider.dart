import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/channel_repository.dart';
import '../data/models/channel.dart';
import '../data/models/channel_list.dart';

// Repository provider
final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  return ChannelRepository();
});

// Channel list provider
final channelListProvider = FutureProvider<ChannelList>((ref) async {
  final repository = ref.watch(channelRepositoryProvider);
  return await repository.loadChannelList();
});

// Current channel index provider
final channelIndexProvider = StateProvider<int>((ref) => 0);

// Active channels provider
final activeChannelsProvider = Provider<List<Channel>>((ref) {
  final channelListAsync = ref.watch(channelListProvider);
  return channelListAsync.maybeWhen(
    data: (channelList) {
      final repository = ref.watch(channelRepositoryProvider);
      return repository.getActiveChannels(channelList.channels);
    },
    orElse: () => [],
  );
});

// Channels sorted by order
final channelsByOrderProvider = Provider<List<Channel>>((ref) {
  final activeChannels = ref.watch(activeChannelsProvider);
  final repository = ref.watch(channelRepositoryProvider);
  return repository.sortChannelsByOrder(activeChannels);
});

// Current channel provider
final currentChannelProvider = Provider<Channel?>((ref) {
  final channels = ref.watch(channelsByOrderProvider);
  final index = ref.watch(channelIndexProvider);
  if (channels.isEmpty || index < 0 || index >= channels.length) {
    return null;
  }
  return channels[index];
});
