import '../../core/utils/link_validator.dart';
import '../models/channel.dart';

class LinkValidatorService {
  final LinkValidator _validator = LinkValidator();

  Future<bool> validateStreamUrl(String url) async {
    return await _validator.validateStreamUrl(url);
  }

  Future<List<String>> findAlternativeUrls(String channelId) async {
    // TODO: Implement searching online databases for working streams
    // For now, return empty list
    return [];
  }

  // Lazy validation: validate URLs on playback failure
  Future<String?> getWorkingUrl(List<StreamUrl> urls) async {
    for (final streamUrl in urls) {
      if (await validateStreamUrl(streamUrl.url)) {
        return streamUrl.url;
      }
    }
    return null;
  }
}
