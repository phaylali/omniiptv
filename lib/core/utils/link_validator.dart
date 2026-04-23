import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

class LinkValidator {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: AppConstants.linkValidationTimeout,
      receiveTimeout: AppConstants.linkValidationTimeout,
    ),
  );

  Future<bool> validateStreamUrl(String url) async {
    try {
      final response = await _dio.head(url);
      // Check if status is 2xx
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Optionally check content-type for video/audio
        final contentType = response.headers.value('content-type');
        if (contentType != null &&
            (contentType.contains('video') ||
                contentType.contains('audio') ||
                contentType.contains('application/x-mpegURL'))) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
