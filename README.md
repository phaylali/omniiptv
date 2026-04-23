# OmniIPTV

OmniIPTV is a Flutter-based IPTV application designed for TV streaming on Linux desktop and Android TV devices. It provides a full-screen TV interface with keyboard/remote controls, multi-protocol streaming support, and an intuitive overlay system for channel management.

## Features

- **Full-Screen TV Interface**: Immersive viewing experience with no visible UI by default
- **Keyboard & Remote Controls**: Navigate channels (up/down), adjust volume (left/right), show/hide overlays (Enter/Escape)
- **Overlay System**:
  - Right-side icon column for quick access
  - Top channel switch notifications
  - Channel list grid for browsing
  - Info display for current channel
  - Volume slider
  - Settings for channel management
- **Multi-Protocol Streaming**: Primary HLS support with DASH/RTMP/progressive fallbacks
- **Channel Management**: Enable/disable channels, reorder, update from online sources
- **Platform Support**: Linux desktop with F11 fullscreen, Android TV with immersive mode
- **Automatic Updates**: Periodic fetching of channel lists from iptv-org
- **State Persistence**: Saves channel settings and preferences locally

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [iptv-org](https://github.com/iptv-org/iptv) for channel data
- Flutter community for amazing framework
- Tabler Icons for UI icons
