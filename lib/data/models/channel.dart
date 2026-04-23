import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

part 'channel.g.dart';

enum StreamProtocol { hls, dash, rtmp, progressive }

@JsonSerializable()
class Channel {
  final String id;
  final String name;
  final String iconName; // e.g., 'tabler_news' for TablerIcons.news
  final List<StreamUrl> streamUrls;
  final String? country;
  final String? category;
  final int order;
  final bool isActive;

  Channel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.streamUrls,
    this.country,
    this.category,
    required this.order,
    required this.isActive,
  });

  // IconData getter - will map iconName to actual IconData
  IconData get icon => _mapIconNameToData(iconName);

  IconData _mapIconNameToData(String name) {
    switch (name) {
      case 'tabler_news':
        return TablerIcons.news;
      case 'tabler_tv':
        return TablerIcons.device_tv;
      case 'tabler_soccer':
        return TablerIcons.ball_football;
      case 'tabler_movie':
        return TablerIcons.movie;
      case 'tabler_balloon':
        return TablerIcons.balloon;
      case 'tabler_books':
        return TablerIcons.books;
      case 'tabler_music':
        return TablerIcons.music;
      case 'tabler_cross':
        return TablerIcons.cross;
      default:
        return TablerIcons.device_tv;
    }
  }

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}

@JsonSerializable()
class StreamUrl {
  final String url;
  final StreamProtocol protocol;
  final int quality;

  StreamUrl({required this.url, required this.protocol, required this.quality});

  factory StreamUrl.fromJson(Map<String, dynamic> json) =>
      _$StreamUrlFromJson(json);
  Map<String, dynamic> toJson() => _$StreamUrlToJson(this);
}
