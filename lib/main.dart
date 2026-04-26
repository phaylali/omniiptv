import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'router.dart';
import 'providers/channel_provider.dart';
import 'data/services/auto_export_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  // Small delay to ensure EGL context is ready on Linux
  if (Platform.isLinux) {
    await Future.delayed(const Duration(milliseconds: 200));
  }
  // Initialize media_kit
  MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Automated channel export on startup (Desktop only)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final repository = ref.read(channelRepositoryProvider);
        final channelList = await repository.loadAllChannels();
        await AutoExportService.checkAndExport(channelList.channels);
      } catch (e) {
        // Silent fail on startup export
      }
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OmniIPTV',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
