# OmniIPTV

OmniIPTV is a Flutter-based IPTV application designed for TV streaming on Linux desktop and Android TV devices. It provides a full-screen TV interface with keyboard/remote controls, multi-protocol streaming support, and an intuitive overlay system for channel management.

## Features

- **Home Dashboard**: Dedicated landing page to choose between watching TV or managing settings
- **Standalone Settings Page**: Full-screen management interface outside of the player
- **M3U Export/Import**: Export your curated channel list to M3U or import external playlists
- **Resource Optimized Playback**: Capped HD streams at 720p and SD at 480p to ensure smooth playback on lower-end devices
- **CPU Efficient**: Disabled heavy post-processing (interpolation, deinterlacing) to minimize CPU usage and lag
- **Long-Press Reordering**: Vertical reordering of channels via long-press in settings
- **Overlay System**:
  - Side navigation column for quick access to overlays
  - Top channel switch notifications with large logos and channel numbers
  - Focused channel list for easy D-pad browsing
  - Premium Volume overlay with high-visibility progress bar
- **Logos & Metadata**: Integrated channel logos with fallback icon system
- **State Persistence**: Saves channel order, active states, and volume locally
- **Maintenance Tools**: Python script for automated migration to modern Flutter syntax

## Screenshots

*(Add screenshots here when available)*

## Installation

### Prerequisites

- Flutter SDK (version 3.13.0 or higher)
- Dart SDK
- For Linux: `libmpv` (required by media_kit)
- Android Studio for Android TV development

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/omniiptv.git
   cd omniiptv
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate JSON serialization files:
   ```bash
   flutter pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run -d linux  # For Linux desktop
   flutter run -d android  # For Android TV
   ```

## Usage

### Controls

- **Enter/OK**: Toggle Side Menu or Select focused item
- **Backspace**: Go Back, Hide Overlay, or Return to Home Dashboard
- **Arrows (Up/Down)**: Switch channels or navigate menus
- **Arrows (Left/Right)**: Adjust volume
- **F11 (Linux)**: Fullscreen toggle

### Overlays

- Press Enter to show the side navigation column
- Select icons to open respective overlays:
  - Settings: Manage channels, reorder, and import playlists
  - Channel List: Browse and select channels with D-pad
  - Info: View current channel details
  - Volume: Adjust volume with high-visibility bar

### Settings

- Enable/disable individual channels
- Reorder channels using **Long-Press** on the OK/Enter button
- Import custom M3U playlists from URL

## Maintenance Tools

### Opacity Refactoring Script
Location: `tool/refactor_opacity.py`
Automates the migration from `.withOpacity(x)` to the modern `.withValues(alpha: x)` syntax.
Usage: `python3 tool/refactor_opacity.py`

## Important Notes

### Streaming Requirements

- **Geo-blocking**: Moroccan TV streams are restricted outside Morocco
- **VPN Recommended**: Use a VPN set to Moroccan location for stream access
- **Network**: Stable internet connection required
- **Performance**: Configured for hardware acceleration with fallback to software rendering

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Acknowledgments

- [iptv-org](https://github.com/iptv-org/iptv) for channel data
- Flutter community for the amazing framework
- Tabler Icons for UI icons

## License

MIT License

## Support Us

<p align="center">
  <a href="https://ko-fi.com/omniversify">
    <img src="https://raw.githubusercontent.com/phaylali/Omniversify/main/public/images/kofi_logo.svg" width="200" alt="Ko-Fi" />
  </a>
</p>

<p align="center">
  <strong>Keep us going</strong>
</p>

---

&copy; 2026 [Omniversify](https://omniversify.com). All rights reserved.

_Made by Moroccans, for the Omniverse_

[![ReadMeSupportPalestine](https://raw.githubusercontent.com/Safouene1/support-palestine-banner/master/banner-project.svg)](https://donate.unrwa.org/-landing-page/en_EN)
