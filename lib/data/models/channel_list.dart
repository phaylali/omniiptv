import 'package:json_annotation/json_annotation.dart';
import 'channel.dart';

part 'channel_list.g.dart';

@JsonSerializable()
class ChannelList {
  final String version;
  final List<Channel> channels;
  final DateTime lastUpdated;
  final String source;

  ChannelList({
    required this.version,
    required this.channels,
    required this.lastUpdated,
    required this.source,
  });

  factory ChannelList.fromJson(Map<String, dynamic> json) =>
      _$ChannelListFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelListToJson(this);
}
