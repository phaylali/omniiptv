import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/channel_list.dart';

class StorageService {
  static const String _channelListKey = 'channel_list';
  static const String _currentChannelIdKey = 'current_channel_id';
  static const String _volumeKey = 'volume';

  static Future<void> saveChannelList(ChannelList channelList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(channelList.toJson());
    await prefs.setString(_channelListKey, jsonString);
  }

  static Future<ChannelList?> loadChannelList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_channelListKey);
    if (jsonString == null) return null;
    final jsonData = json.decode(jsonString);
    return ChannelList.fromJson(jsonData);
  }

  static Future<void> saveCurrentChannelId(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentChannelIdKey, channelId);
  }

  static Future<String?> loadCurrentChannelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentChannelIdKey);
  }

  static Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  static Future<double> loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 0.4;
  }
}
