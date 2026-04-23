import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OverlayType { channelList, info, settings, volume }

// Show overlay provider
final showOverlayProvider = StateProvider<bool>((ref) => false);

// Overlay type provider
final overlayTypeProvider = StateProvider<OverlayType>(
  (ref) => OverlayType.channelList,
);
