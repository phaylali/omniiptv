# OmniIPTV

OmniIPTV is a Flutter-based IPTV application designed for TV streaming on Linux desktop and Android TV devices. It provides a full-screen TV interface with keyboard/remote controls, multi-protocol streaming support, and an intuitive overlay system for channel management.

## Features

- **Full-Screen TV Interface**: Immersive viewing experience with no visible UI by default
- **Dual Quality Streams**: Automatically generated SD (480p) variants for every channel for smooth playback
- **Keyboard & Remote Controls**: Optimized for D-pad navigation and media keys
- **Overlay System**:
  - Right-side icon column for quick access
  - Top channel switch notifications with logos
  - Vertical channel list for easy browsing
  - Settings for channel management (reorder, enable/disable, import)
- **Logos & Metadata**: Integrated channel logos with fallback icon system
- **Multi-Protocol Streaming**: HLS support with adaptive bitrate via `media_kit`
- **Channel Management**: Reorder channels with drag-and-drop, custom M3U import
- **Platform Support**: Linux desktop (F11 fullscreen) and Android TV (immersive)
- **State Persistence**: Saves channel order and preferences locally

## Screenshots

*(Add screenshots here when available)*

## Installation

### Prerequisites

- Flutter SDK (version 3.13.0 or higher)
- Dart SDK
- For Linux: `libkeybinder-3.0-dev` for hotkey support (if using hotkeys)
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

- **Channel Navigation**: Up/Down arrow keys or remote D-pad
- **Volume Control**: Left/Right arrow keys
- **Show Overlays**: Enter key or remote OK button
- **Hide Overlays**: Escape key or remote Back button
- **Fullscreen (Linux)**: F11 key

### Overlays

- Press Enter to show the right-side icon column
- Select icons to open respective overlays:
  - Settings: Manage channels, update from online
  - Channel List: Browse and select channels
  - Info: View current channel details
  - Volume: Adjust volume with slider

### Settings

- Enable/disable individual channels
- Reorder channels with drag-and-drop
- Update channel list from iptv-org for latest streams

## Important Notes

### Streaming Requirements

- **Geo-blocking**: Moroccan TV streams are restricted outside Morocco
- **VPN Recommended**: Use a VPN set to Moroccan location for stream access
- **Network**: Stable internet connection required (streams may buffer on slow connections)
- **Platform Differences**: Android may work better than Linux due to codec support

## Building

### Linux Desktop

```bash
flutter build linux
```

### Android TV

```bash
flutter build apk --target-platform android-arm64
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Submit a pull request
## Acknowledgments

- [iptv-org](https://github.com/iptv-org/iptv) for channel data
- Flutter community for amazing framework
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
