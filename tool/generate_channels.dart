import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('assets/morocco.m3u');
  final content = file.readAsStringSync();
  final lines = content.split('\n');

  final channels = <Map<String, dynamic>>[];
  String? currentName;
  String? currentGroup;
  String? currentUrl;

  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('#EXTINF:')) {
      // Extract name after comma
      final commaIdx = line.lastIndexOf(',');
      currentName = commaIdx != -1
          ? line.substring(commaIdx + 1).trim()
          : 'Unknown';
      // Extract group-title
      final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);
      currentGroup = groupMatch?.group(1) ?? 'Other';
    } else if (line.isNotEmpty &&
        !line.startsWith('#') &&
        currentName != null) {
      currentUrl = line;
      // Determine protocol
      String protocol = 'hls';
      if (currentUrl.contains('.mpd')) {
        protocol = 'dash';
      } else if (currentUrl.contains('rtmp://')) {
        protocol = 'rtmp';
      } else if (!currentUrl.contains('.m3u8')) {
        protocol = 'progressive';
      }

      // Determine icon based on group or name
      String iconName = 'tabler_tv'; // default
      final lowerName = currentName.toLowerCase();
      if (currentGroup?.contains('SNRT Sport') ?? false) {
        iconName = 'tabler_soccer';
      } else if (currentGroup?.contains('Medi1') ?? false) {
        iconName = 'tabler_news';
      } else if (currentGroup?.contains('SNRT') ?? false) {
        // SNRT general channels
        if (lowerName.contains('aoula')) {
          iconName = 'tabler_news'; // Al Aoula - news/general
        } else if (lowerName.contains('maghribia')) {
          iconName = 'tabler_tv'; // entertainment
        } else if (lowerName.contains('assadissa')) {
          iconName = 'tabler_balloon'; // kids
        } else if (lowerName.contains('tamazight')) {
          iconName = 'tabler_books'; // cultural/berber
        } else if (lowerName.contains('athaqafia')) {
          iconName = 'tabler_books'; // culture
        } else if (lowerName.contains('aflam')) {
          iconName = 'tabler_movie'; // movies
        } else if (lowerName.contains('laayoune')) {
          iconName = 'tabler_tv';
        } else {
          iconName = 'tabler_tv';
        }
      } else if (currentGroup?.contains('2M') ?? false) {
        iconName = 'tabler_tv';
      } else {
        // Other
        iconName = 'tabler_tv';
      }

      // Generate ID
      final id = currentName.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '_',
      );

      channels.add({
        'id': id,
        'name': currentName,
        'iconName': iconName,
        'streamUrls': [
          {'url': currentUrl, 'protocol': protocol, 'quality': 0},
        ],
        'country': 'Morocco',
        'category': currentGroup ?? 'General',
        'order': channels.length + 1,
        'isActive': true,
      });

      currentName = null;
      currentUrl = null;
    }
  }

  final output = {
    'version': '1.0.0',
    'lastUpdated': DateTime.now().toIso8601String(),
    'source': 'assets/morocco.m3u',
    'channels': channels,
  };

  final outFile = File('assets/channels_generated.json');
  final jsonEncoder = JsonEncoder.withIndent('  ');
  outFile.writeAsStringSync(jsonEncoder.convert(output));
  print(
    'Generated ${channels.length} channels to assets/channels_generated.json',
  );
}
