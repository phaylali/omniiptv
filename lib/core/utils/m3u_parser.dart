import '../../data/models/channel.dart';

class M3UParser {
  /// Parse M3U content into a list of Channel objects
  ///
  /// M3U format:
  /// #EXTM3U
  /// #EXTINF:-1 tvg-id="..." tvg-name="..." tvg-logo="...",Channel Name
  /// http://stream.url/...
  static Future<List<Channel>> parse(
    String content, {
    String source = 'user_import',
  }) async {
    final lines = content.split('\n');
    final List<Channel> channels = [];
    Channel? currentChannel;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF:')) {
        // Parse EXTINF line
        final name = _extractChannelName(line);
        final tvgId = _extractTvgId(line);

        currentChannel = Channel(
          id: _generateChannelId(name, tvgId, channels.length),
          name: name,
          iconName: 'tabler_tv',
          streamUrls: [],
          country: 'Morocco',
          category: _extractCategory(line),
          order: channels.length + 1,
          isActive: true,
        );
      } else if (line.isNotEmpty &&
          !line.startsWith('#') &&
          currentChannel != null) {
        // This is a stream URL line
        final protocol = _detectProtocol(line);
        currentChannel = currentChannel.copyWith(
          streamUrls: [
            ...currentChannel.streamUrls,
            StreamUrl(url: line, protocol: protocol, quality: 0),
          ],
        );

        // Add completed channel to list
        channels.add(currentChannel);
        currentChannel = null;
      }
    }

    return channels;
  }

  static String _extractChannelName(String extinfLine) {
    // Format: #EXTINF:-1 tvg-id="..." tvg-name="..." tvg-logo="...",Channel Name
    final lastCommaIndex = extinfLine.lastIndexOf(',');
    if (lastCommaIndex != -1 && lastCommaIndex < extinfLine.length - 1) {
      return extinfLine.substring(lastCommaIndex + 1).trim();
    }
    return 'Unknown Channel';
  }

  static String _extractTvgId(String extinfLine) {
    final tvgIdMatch = RegExp(r'tvg-id="([^"]*)"').firstMatch(extinfLine);
    if (tvgIdMatch != null) {
      return tvgIdMatch.group(1)!;
    }
    return '';
  }

  static String? _extractCategory(String extinfLine) {
    final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(extinfLine);
    if (groupMatch != null) {
      return groupMatch.group(1);
    }
    return null;
  }

  static StreamProtocol _detectProtocol(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.m3u8')) {
      return StreamProtocol.hls;
    } else if (lowerUrl.contains('.mpd')) {
      return StreamProtocol.dash;
    } else if (lowerUrl.contains('rtmp://')) {
      return StreamProtocol.rtmp;
    } else {
      return StreamProtocol.progressive;
    }
  }

  static String _generateChannelId(String name, String? tvgId, int index) {
    if (tvgId != null) {
      return tvgId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    }
    // Generate ID from name
    final normalized = name.toLowerCase().replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '_',
    );
    return '${normalized}_$index';
  }
}

// Extension to create a copy of Channel with modified fields
extension ChannelCopyWith on Channel {
  Channel copyWith({
    String? id,
    String? name,
    String? iconName,
    List<StreamUrl>? streamUrls,
    String? country,
    String? category,
    int? order,
    bool? isActive,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      streamUrls: streamUrls ?? this.streamUrls,
      country: country ?? this.country,
      category: category ?? this.category,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}
