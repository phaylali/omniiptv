import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/channel_loader.dart';
import '../models/channel.dart';
import '../models/channel_list.dart';
import '../models/user_channel_data.dart';
import '../services/link_validator_service.dart';
import '../services/m3u_import_service.dart';

class ChannelRepository {
  final LinkValidatorService _validatorService = LinkValidatorService();
  final M3UImportService _importService = M3UImportService();

  /// Load all channels (including inactive) with user modifications
  Future<ChannelList> loadAllChannels() async {
    final bundled = await ChannelLoader.loadChannels();
    final userData = await _loadUserData();

    var channels = List<Channel>.from(bundled.channels);

    // Apply overrides (isActive, streamUrls)
    for (final override in userData.channelOverrides) {
      final index = channels.indexWhere((c) => c.id == override.id);
      if (index != -1) {
        channels[index] = override;
      }
    }

    // Apply custom order
    if (userData.channelOrder.isNotEmpty) {
      final ordered = <Channel>[];
      final orderSet = userData.channelOrder.toSet();

      // Add in custom order
      for (final id in userData.channelOrder) {
        for (final channel in channels) {
          if (channel.id == id) {
            ordered.add(channel);
            break;
          }
        }
      }

      // Append remaining sorted by order field
      final remaining = channels
          .where((c) => !orderSet.contains(c.id))
          .toList();
      remaining.sort((a, b) => a.order.compareTo(b.order));
      channels = [...ordered, ...remaining];
    } else {
      channels.sort((a, b) => a.order.compareTo(b.order));
    }

    // Append imported channels
    if (userData.importedChannels.isNotEmpty) {
      final maxOrder = channels.isEmpty
          ? 0
          : channels.map((c) => c.order).reduce((a, b) => a > b ? a : b);
      final importedWithOrder = userData.importedChannels.asMap().entries.map((
        entry,
      ) {
        return entry.value.copyWith(order: maxOrder + entry.key + 1);
      }).toList();
      channels.addAll(importedWithOrder);
    }

    return ChannelList(
      version: bundled.version,
      channels: channels,
      lastUpdated: DateTime.now(),
      source: 'merged:${bundled.source}:user',
    );
  }

  /// Load only active channels (for TV playback)
  Future<ChannelList> loadChannels() async {
    final all = await loadAllChannels();
    final active = all.channels.where((c) => c.isActive).toList();
    return ChannelList(
      version: all.version,
      channels: active,
      lastUpdated: all.lastUpdated,
      source: all.source,
    );
  }

  Future<UserChannelData> _loadUserData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/channels_user.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return UserChannelData.fromJson(json);
      }
    } catch (e) {
      // Fall through to empty data
    }
    return UserChannelData.empty();
  }

  Future<void> saveUserChannelData(UserChannelData userData) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/channels_user.json');
      final json = userData.toJson();
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      throw Exception('Failed to save user channel data: $e');
    }
  }

  Future<void> updateChannelOrder(List<String> channelIdsInOrder) async {
    final userData = await _loadUserData();
    final updated = userData.copyWith(
      channelOrder: channelIdsInOrder,
      lastUpdated: DateTime.now(),
    );
    await saveUserChannelData(updated);
  }

  Future<void> updateChannelOverrides(List<Channel> overrides) async {
    final userData = await _loadUserData();
    final updated = userData.copyWith(
      channelOverrides: overrides,
      lastUpdated: DateTime.now(),
    );
    await saveUserChannelData(updated);
  }

  Future<ImportResult> importM3U(String url, {bool append = false}) async {
    final result = await _importService.importFromUrl(url, append: append);

    if (result.parsedChannels.isNotEmpty) {
      final userData = await _loadUserData();
      final mergedImported = List<Channel>.from(userData.importedChannels);
      mergedImported.addAll(result.parsedChannels);

      final updated = userData.copyWith(
        importedChannels: mergedImported,
        lastUpdated: DateTime.now(),
      );
      await saveUserChannelData(updated);
    }

    return result;
  }
}
