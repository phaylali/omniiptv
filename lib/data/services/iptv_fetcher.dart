import 'package:dio/dio.dart';
import '../models/channel.dart';

class IptvFetcher {
  final Dio _dio = Dio();

  Future<List<Channel>> fetchMoroccanChannels() async {
    try {
      final response = await _dio.get(
        'https://iptv-org.github.io/iptv/countries/ma.m3u',
      );
      final m3uContent = response.data as String;
      return _parseM3u(m3uContent);
    } catch (e) {
      return [];
    }
  }

  List<Channel> _parseM3u(String content) {
    final lines = content.split('\n');
    final channels = <Channel>[];

    String? currentName;
    String? currentUrl;

    for (final line in lines) {
      if (line.startsWith('#EXTINF:')) {
        // Extract name, e.g., #EXTINF:-1,Al Aoula
        final parts = line.split(',');
        if (parts.length > 1) {
          currentName = parts[1].trim();
        }
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        currentUrl = line.trim();
        if (currentName != null && currentUrl != null) {
          final id = currentName.toLowerCase().replaceAll(' ', '_');
          channels.add(
            Channel(
              id: id,
              name: currentName,
              iconName: 'tabler_tv', // Default icon
              streamUrls: [
                StreamUrl(
                  url: currentUrl,
                  protocol: StreamProtocol.hls, // Assume HLS
                  quality: 0,
                ),
              ],
              country: 'Morocco',
              category: 'General', // Default
              order: channels.length + 1,
              isActive: true,
            ),
          );
          currentName = null;
          currentUrl = null;
        }
      }
    }

    return channels;
  }
}
