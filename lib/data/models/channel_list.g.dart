// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelList _$ChannelListFromJson(Map<String, dynamic> json) => ChannelList(
  version: json['version'] as String,
  channels: (json['channels'] as List<dynamic>)
      .map((e) => Channel.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  source: json['source'] as String,
);

Map<String, dynamic> _$ChannelListToJson(ChannelList instance) =>
    <String, dynamic>{
      'version': instance.version,
      'channels': instance.channels,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'source': instance.source,
    };
