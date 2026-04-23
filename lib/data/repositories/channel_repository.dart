import '../../core/utils/channel_loader.dart';
import '../../core/utils/storage_service.dart';
import '../models/channel.dart';
import '../models/channel_list.dart';
import '../services/link_validator_service.dart';

class ChannelRepository {
  final LinkValidatorService _validatorService = LinkValidatorService();

  Future<ChannelList> loadChannelList() async {
    // Try loading from storage first
    ChannelList? stored = await StorageService.loadChannelList();
    if (stored != null) {
      return stored;
    }

    // Fallback to assets
    return await ChannelLoader.loadChannels();
  }

  Future<void> saveChannelList(ChannelList channelList) async {
    await StorageService.saveChannelList(channelList);
  }

  List<Channel> getActiveChannels(List<Channel> channels) {
    return channels.where((channel) => channel.isActive).toList();
  }

  List<Channel> sortChannelsByOrder(List<Channel> channels) {
    return List.from(channels)..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<String?> getWorkingUrlForChannel(Channel channel) async {
    return await _validatorService.getWorkingUrl(channel.streamUrls);
  }
}
