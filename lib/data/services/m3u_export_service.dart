import '../models/channel.dart';

class M3UExportService {
  static String generateM3U(List<Channel> channels) {
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    
    for (final channel in channels) {
      // Skip inactive channels if desired, or include them all
      // For export, we usually want everything that's available
      final logoAttr = channel.logoUrl != null ? ' tvg-logo="${channel.logoUrl}"' : '';
      final categoryAttr = channel.category != null ? ' group-title="${channel.category}"' : '';
      
      buffer.writeln('#EXTINF:-1 tvg-id="${channel.id}"$logoAttr$categoryAttr,${channel.name}');
      
      // Use the first available stream URL or all of them as separate entries?
      // Standard M3U usually has one URL per INF.
      if (channel.streamUrls.isNotEmpty) {
        buffer.writeln(channel.streamUrls.first.url);
      }
    }
    
    return buffer.toString();
  }
}
