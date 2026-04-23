/// Application-wide constants
class AppConstants {
  // Overlay settings
  static const Duration overlayAutoHideDuration = Duration(seconds: 5);
  static const double defaultVolume = 0.4;

  // UI settings
  static const double iconSize = 24.0;
  static const double iconSpacing = 16.0;
  static const double overlayOpacity = 0.8;
  static const double overlayBlurIntensity = 10.0;

  // Channel update settings
  static const Duration channelUpdateInterval = Duration(
    hours: 24,
  ); // Automatic periodic fetch

  // Link validation settings
  static const Duration linkValidationTimeout = Duration(seconds: 3);
}
