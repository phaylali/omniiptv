import 'package:json_annotation/json_annotation.dart';
import 'channel.dart';

part 'user_channel_data.g.dart';

@JsonSerializable()
class UserChannelData {
  final String version;
  final DateTime lastUpdated;
  final List<String> channelOrder; // Ordered list of channel IDs
  final List<Channel>
  channelOverrides; // Partial updates (isActive, streamUrls)
  final List<Channel> importedChannels; // Channels from M3U imports

  UserChannelData({
    required this.version,
    required this.lastUpdated,
    required this.channelOrder,
    required this.channelOverrides,
    required this.importedChannels,
  });

  factory UserChannelData.empty() {
    return UserChannelData(
      version: '1.0.0',
      lastUpdated: DateTime.now(),
      channelOrder: [],
      channelOverrides: [],
      importedChannels: [],
    );
  }

  factory UserChannelData.fromJson(Map<String, dynamic> json) =>
      _$UserChannelDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserChannelDataToJson(this);

  // CopyWith method
  UserChannelData copyWith({
    String? version,
    DateTime? lastUpdated,
    List<String>? channelOrder,
    List<Channel>? channelOverrides,
    List<Channel>? importedChannels,
  }) {
    return UserChannelData(
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      channelOrder: channelOrder ?? this.channelOrder,
      channelOverrides: channelOverrides ?? this.channelOverrides,
      importedChannels: importedChannels ?? this.importedChannels,
    );
  }
}
