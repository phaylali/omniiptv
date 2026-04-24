import 'dart:io';
import 'package:dio/dio.dart';
import '../../data/models/channel.dart';
import '../../core/utils/m3u_parser.dart';

class M3UImportService {
  final Dio _dio = Dio();

  Future<ImportResult> importFromUrl(String url, {bool append = false}) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        final content = response.data as String;
        return await parseAndMerge(content, source: url, append: append);
      } else {
        return ImportResult(
          channelsAdded: 0,
          channelsUpdated: 0,
          conflictsResolved: 0,
          errors: ['HTTP error: ${response.statusCode}'],
          duplicateNames: {},
          parsedChannels: [],
        );
      }
    } catch (e) {
      return ImportResult(
        channelsAdded: 0,
        channelsUpdated: 0,
        conflictsResolved: 0,
        errors: ['Failed to fetch M3U: $e'],
        duplicateNames: {},
        parsedChannels: [],
      );
    }
  }

  Future<ImportResult> importFromFile(
    String filePath, {
    bool append = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(
          channelsAdded: 0,
          channelsUpdated: 0,
          conflictsResolved: 0,
          errors: ['File not found: $filePath'],
          duplicateNames: {},
          parsedChannels: [],
        );
      }
      final content = await file.readAsString();
      return await parseAndMerge(content, source: filePath, append: append);
    } catch (e) {
      return ImportResult(
        channelsAdded: 0,
        channelsUpdated: 0,
        conflictsResolved: 0,
        errors: ['Failed to read file: $e'],
        duplicateNames: {},
        parsedChannels: [],
      );
    }
  }

  Future<ImportResult> parseAndMerge(
    String content, {
    required String source,
    bool append = false,
  }) async {
    final parsedChannels = await M3UParser.parse(content, source: source);

    return ImportResult(
      channelsAdded: parsedChannels.length,
      channelsUpdated: 0,
      conflictsResolved: 0,
      errors: [],
      duplicateNames: {},
      parsedChannels: parsedChannels,
    );
  }
}

class ImportResult {
  final int channelsAdded;
  final int channelsUpdated;
  final int conflictsResolved;
  final List<String> errors;
  final Set<String> duplicateNames;
  final List<Channel> parsedChannels;

  ImportResult({
    required this.channelsAdded,
    required this.channelsUpdated,
    required this.conflictsResolved,
    required this.errors,
    required this.duplicateNames,
    required this.parsedChannels,
  });
}
