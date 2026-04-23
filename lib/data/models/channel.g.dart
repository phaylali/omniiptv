// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
  id: json['id'] as String,
  name: json['name'] as String,
  iconName: json['iconName'] as String,
  streamUrls: (json['streamUrls'] as List<dynamic>)
      .map((e) => StreamUrl.fromJson(e as Map<String, dynamic>))
      .toList(),
  country: json['country'] as String?,
  category: json['category'] as String?,
  order: (json['order'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'iconName': instance.iconName,
  'streamUrls': instance.streamUrls,
  'country': instance.country,
  'category': instance.category,
  'order': instance.order,
  'isActive': instance.isActive,
};

StreamUrl _$StreamUrlFromJson(Map<String, dynamic> json) => StreamUrl(
  url: json['url'] as String,
  protocol: $enumDecode(_$StreamProtocolEnumMap, json['protocol']),
  quality: (json['quality'] as num).toInt(),
);

Map<String, dynamic> _$StreamUrlToJson(StreamUrl instance) => <String, dynamic>{
  'url': instance.url,
  'protocol': _$StreamProtocolEnumMap[instance.protocol]!,
  'quality': instance.quality,
};

const _$StreamProtocolEnumMap = {
  StreamProtocol.hls: 'hls',
  StreamProtocol.dash: 'dash',
  StreamProtocol.rtmp: 'rtmp',
  StreamProtocol.progressive: 'progressive',
};
