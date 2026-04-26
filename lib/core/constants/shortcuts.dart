import 'package:flutter/services.dart';

/// Keyboard shortcuts and key mappings
class AppShortcuts {
  // Channel navigation
  static const LogicalKeyboardKey channelUp = LogicalKeyboardKey.arrowUp;
  static const LogicalKeyboardKey channelDown = LogicalKeyboardKey.arrowDown;

  // Volume control
  static const LogicalKeyboardKey volumeUp = LogicalKeyboardKey.arrowRight;
  static const LogicalKeyboardKey volumeDown = LogicalKeyboardKey.arrowLeft;

  // Overlay control
  static const LogicalKeyboardKey showOverlay = LogicalKeyboardKey.enter;
  static const LogicalKeyboardKey hideOverlay = LogicalKeyboardKey.backspace;

  // Fullscreen toggle (Linux)
  static const LogicalKeyboardKey toggleFullscreen = LogicalKeyboardKey.f11;
}
