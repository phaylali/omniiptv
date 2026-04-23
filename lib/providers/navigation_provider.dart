import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoutePath { tv, settings }

// Current route provider
final currentRouteProvider = StateProvider<RoutePath>((ref) => RoutePath.tv);

// Navigation stack provider
final navigationStackProvider = Provider<List<RoutePath>>((ref) {
  final current = ref.watch(currentRouteProvider);
  return [current]; // Simplified, just current
});
