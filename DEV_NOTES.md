# OmniIPTV Developer Notes

## Overview

OmniIPTV is a Flutter application implementing a TV streaming interface with IPTV capabilities. Built using Flutter for cross-platform support, it targets Linux desktop and Android TV devices.

**Current Status**: Core UI and navigation fully implemented. IPTV streaming has geo-blocking limitations requiring VPN access for Moroccan channels.

## Architecture

### State Management

- **Riverpod**: Used for reactive state management throughout the app
- Providers handle channel lists, player state, overlays, and navigation
- StateNotifier and FutureProvider for async operations

### Routing

- **go_router**: Declarative routing with path-based navigation
- Routes: `/tv` (main screen), `/settings` (future use)

### Data Layer

- **Models**: Channel, StreamUrl, ChannelList with JSON serialization
- **Repositories**: ChannelRepository for data access and business logic
- **Services**: LinkValidatorService for stream validation, IptvFetcher for online updates
- **Storage**: SharedPreferences for local persistence

### UI Layer

- **Pages**: TvScreenPage as main interface
- **Widgets**: Modular components for overlays, player, notifications
- **Themes**: Material 3 with custom dark theme for TV viewing

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart    # App-wide constants (timers, defaults)
│   │   └── shortcuts.dart        # Keyboard mappings
│   ├── utils/
│   │   ├── channel_loader.dart   # Loads channels from assets
│   │   ├── link_validator.dart   # HTTP validation utility
│   │   └── storage_service.dart  # SharedPreferences wrapper
├── data/
│   ├── models/
│   │   ├── channel.dart          # Channel and StreamUrl models
│   │   └── channel_list.dart     # Channel collection model
│   ├── repositories/
│   │   └── channel_repository.dart # Data access layer
│   ├── services/
│   │   ├── iptv_fetcher.dart     # Online channel fetching
│   │   └── link_validator_service.dart # Stream validation
├── providers/
│   ├── channel_provider.dart     # Channel state providers
│   ├── player_provider.dart      # Video player state
│   ├── overlay_provider.dart     # Overlay state
│   ├── navigation_provider.dart  # Route state
│   └── settings_provider.dart    # App settings
├── presentation/
│   ├── pages/
│   │   ├── tv_screen_page.dart   # Main TV screen
│   │   └── settings_page.dart    # Settings page
│   ├── widgets/
│   │   ├── video_player_widget.dart     # Video player component
│   │   ├── overlay_column.dart          # Right-side icon column
│   │   ├── channel_notification.dart    # Top notification
│   │   ├── channel_list_overlay.dart    # Channel grid
│   │   ├── info_overlay.dart            # Channel info
│   │   ├── volume_overlay.dart          # Volume control
│   │   └── settings_overlay.dart        # Settings management
assets/
├── channels.json               # Initial channel data
```

## Dependencies

### Core
- `flutter_riverpod: ^2.4.0` - State management
- `go_router: ^12.0.0` - Routing
- `shared_preferences: ^2.2.0` - Local storage

### Media
- `video_player: ^2.8.0` - Video playback
- `just_audio: ^0.9.34` - Audio support

### Networking
- `dio: ^5.3.0` - HTTP client
- `archive: ^3.4.0` - Compression handling

### UI/UX
- `flutter_tabler_icons: ^1.43.0` - Icon library
- `google_fonts: ^6.1.0` - Typography
- `flutter_svg: ^2.0.0+1` - SVG support

### Platform
- `window_manager: ^0.3.0` - Linux window management
- `wakelock_plus: ^1.1.0` - Keep screen awake

### Development
- `json_annotation: ^4.8.0` - JSON serialization
- `build_runner: ^2.4.0` - Code generation

## Implementation Details

### Video Playback

- Uses `VideoPlayerController` for HLS/DASH streams
- Fallback URL testing on initialization failure
- Volume synchronization with provider state
- Auto-play on channel change

### Channel Management

- JSON-based channel definitions with multiple fallback URLs
- Lazy validation: Test URLs only on playback failure
- Reorderable list with drag-and-drop
- Atomic file updates for SharedPreferences

### Overlay System

- Stacked widgets with z-index management
- Auto-hide timers (5 seconds inactivity)
- Keyboard/remote navigation support
- Conditional rendering based on overlay type

### Keyboard Handling

- `RawKeyboardListener` for app-focused input
- Logical key mappings for cross-platform compatibility
- Platform-specific handling (F11 fullscreen on Linux)

### Platform Specifics

#### Linux Desktop
- `window_manager` for borderless fullscreen
- Requires `libkeybinder-3.0-dev` for hotkey support (removed in current build)
- X11/Wayland compatibility

#### Android TV
- Immersive mode via `SystemChrome.setEnabledSystemUIMode`
- Back button handling for overlay navigation
- Leanback compatibility considerations

### Data Flow

1. **Channel Loading**: App starts → Load from SharedPreferences → Fallback to assets → Optional online fetch
2. **Stream Playback**: Channel select → Try URLs sequentially → Validate via HEAD request → Play valid stream
3. **Overlay Interaction**: User input → Show overlay → Auto-hide timer → State updates
4. **Settings Updates**: User reorder/enable → Update models → Save to storage → Refresh UI

## API Usage

### iptv-org Integration
- Fetches M3U playlist from `https://iptv-org.github.io/iptv/countries/ma.m3u`
- Parses EXTINF entries for channel names
- Maps to internal Channel model structure
- Automatic periodic updates (24-hour interval)

### Stream Validation
- HEAD requests to check URL accessibility
- Content-Type validation for video/audio streams
- Timeout handling (3 seconds per URL)
- Fallback URL testing on failure

## Known Issues & Limitations

- **Streaming Issues**: IPTV streams may be geo-blocked outside Morocco; requires VPN for access
- Hotkey manager dependency removed due to Linux requirements
- Stream URLs may become outdated; relies on online updates
- Video player initialization may timeout on slow networks (30s timeout implemented)
- No EPG integration (planned for future)
- Limited codec support on some Linux distributions
- Android TV remote focus traversal not fully implemented
- HTTP streams require android:usesCleartextTraffic="true" in AndroidManifest

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Link validation logic
- Storage service operations

### Integration Tests
- Channel switching via keyboard
- Overlay navigation and auto-hide
- Stream URL fallback testing

### Manual Testing
- IPTV stream playback verification (requires VPN for geo-blocked content)
- Platform-specific fullscreen modes
- Keyboard/remote responsiveness
- Channel persistence across sessions
- Overlay auto-hide functionality
- Stream fallback on failure

## Future Improvements

- Fix IPTV streaming reliability (VPN integration, better fallback handling)
- EPG (Electronic Program Guide) integration (High Priority)
- Favorites system for quick access
- Search functionality within channel list
- Advanced stream quality selection (automatic vs manual)
- Parental controls
- Offline channel metadata caching
- Multi-language support
- Better hardware acceleration support for Linux (EGL/Mesa tuning)
- Custom logo upload/override support

## Build & Deployment

### Linux
```bash
flutter build linux --release
# Distribute as AppImage or system package
```

### Android TV
```bash
flutter build apk --target-platform android-arm64 --release
# Sign and publish to Play Store or sideload
```

### CI/CD
- GitHub Actions for automated testing
- Build verification on multiple platforms
- Dependency updates via Dependabot

## Performance Considerations

- Lazy loading of channel data
- Efficient provider watching to minimize rebuilds
- Stream validation timeout to prevent UI blocking
- Minimal widget tree depth for smooth animations
- Platform-specific optimizations (hardware acceleration)

## Security

- No sensitive data stored (only channel preferences)
- HTTPS enforcement for online requests
- Input validation for user-provided URLs
- No network requests without user action (except updates)

## Contributing Guidelines

- Follow Flutter style guide
- Write tests for new features
- Update documentation for API changes
- Use meaningful commit messages
- Test on both target platforms

---

---

*Last updated: 2026-04-24*