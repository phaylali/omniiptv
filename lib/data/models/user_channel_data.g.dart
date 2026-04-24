// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_channel_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChannelData _$UserChannelDataFromJson(Map<String, dynamic> json) =>
    UserChannelData(
      version: json['version'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      channelOrder: (json['channelOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      channelOverrides: (json['channelOverrides'] as List<dynamic>)
          .map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
      importedChannels: (json['importedChannels'] as List<dynamic>)
          .map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserChannelDataToJson(UserChannelData instance) =>
    <String, dynamic>{
      'version': instance.version,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'channelOrder': instance.channelOrder,
      'channelOverrides': instance.channelOverrides,
      'importedChannels': instance.importedChannels,
    };
