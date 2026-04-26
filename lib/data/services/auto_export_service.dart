import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/channel.dart';
import 'm3u_export_service.dart';

class AutoExportService {
  static Future<void> checkAndExport(List<Channel> channels) async {
    // This feature is primarily for desktop development environments
    // where the repo root is accessible.
    if (!Platform.isLinux && !Platform.isWindows && !Platform.isMacOS) {
      return;
    }

    try {
      final m3uContent = M3UExportService.generateM3U(channels);
      final newHash = md5.convert(utf8.encode(m3uContent)).toString();

      // Attempt to find the project root by looking for pubspec.yaml
      Directory current = Directory.current;
      File? pubspec;
      
      // Navigate up to 3 levels to find root (in case we are in build artifacts dir)
      for (int i = 0; i < 3; i++) {
        final testFile = File('${current.path}/pubspec.yaml');
        if (await testFile.exists()) {
          pubspec = testFile;
          break;
        }
        current = current.parent;
      }

      if (pubspec == null) return;

      final exportDir = Directory('${current.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final exportFile = File('${exportDir.path}/morocco.m3u');
      final hashFile = File('${exportDir.path}/.morocco.hash');

      bool shouldWrite = true;
      if (await exportFile.exists() && await hashFile.exists()) {
        final oldHash = await hashFile.readAsString();
        if (oldHash == newHash) {
          shouldWrite = false;
        }
      }

      if (shouldWrite) {
        await exportFile.writeAsString(m3uContent);
        await hashFile.writeAsString(newHash);
        print('Auto-exported channel list to ${exportFile.path}');
      }
    } catch (e) {
      print('Auto-export failed: $e');
    }
  }
}
