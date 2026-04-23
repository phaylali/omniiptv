import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/channel_list.dart';

class ChannelLoader {
  static Future<ChannelList> loadChannels() async {
    final String jsonString = await rootBundle.loadString(
      'assets/channels.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return ChannelList.fromJson(jsonData);
  }
}
