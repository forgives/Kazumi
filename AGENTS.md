# Kazumi - Architecture Overview

## Project Overview

Kazumi is a Flutter-based anime aggregation search and streaming app. Users discover and watch anime through custom XPath-based plugin rules that scrape multiple video sources. The app supports Android, iOS, Windows, macOS, and Linux (experimental).

**Core architecture**: Modular layered pattern with MobX state management and flutter_modular routing/DI.

```
Pages (UI) → Controllers (MobX) → Repositories → Request/API
                                        ↕
                                   Hive CE (local storage)
```

## Key Directories

| Directory | Role |
|-----------|------|
| `lib/pages/` | UI pages organized by feature module (popular, timeline, collect, search, player, settings, etc.) |
| `lib/modules/` | Data models with Hive persistence (bangumi, collect, history, danmaku, download, search) |
| `lib/plugins/` | XPath rule engine - plugin system for video source scraping, anti-crawler config, cookie management |
| `lib/providers/` | Video source resolution layer (WebView parsing, local cache, captcha handling) |
| `lib/repositories/` | Data access layer wrapping Hive storage operations |
| `lib/request/` | HTTP client layer (Dio) with Bangumi API, DanDanPlay API, interceptors |
| `lib/bean/` | Reusable UI widgets (cards, dialogs, app bars, settings components) |
| `lib/utils/` | Utilities (storage, download manager, SyncPlay, WebDAV sync, proxy, M3U8 parser, Anime4K upscaling) |
| `lib/webview/` | Cross-platform WebView implementations per platform |
| `lib/bbcode/` | ANTLR4-based BBCode parser for danmaku/comment rendering |
| `lib/shaders/` | Anime4K GLSL shader controllers for real-time video upscaling |
| `assets/plugins/` | Built-in JSON rule files (AGE, DM84, aafun) |

## Project Structure Details

### Dependencies (pubspec.yaml)

**Core Framework:**
- `flutter_modular`: ^6.3.4 - Routing and dependency injection
- `mobx`: ^2.6.0 + `flutter_mobx`: ^2.3.0 - State management
- `dio`: ^5.0.0 - HTTP client
- `hive_ce`: ^2.16.0 + `hive_ce_flutter`: ^2.3.3 - Local storage

**Video & Audio:**
- `media_kit` (forked) - Core video player
- `canvas_danmaku`: ^0.3.1 - Danmaku rendering
- `audio_service`: ^0.18.15 - Background audio playback
- `flutter_volume_controller`: ^1.3.2 - Volume control

**WebView & Network:**
- `flutter_inappwebview_*`: Platform-specific WebView (Android/iOS/macOS)
- `webview_windows` (git) - Windows WebView
- `desktop_webview_window` (git) - Linux WebView
- `xpath_selector`: ^3.0.2 - XPath parsing for plugin system
- `webdav_client`: ^1.2.2 - WebDAV sync

**UI Components:**
- `dynamic_color`: ^1.8.1 - Material You dynamic colors
- `cached_network_image`: ^3.4.1 - Image caching
- `flutter_svg`: ^2.2.3 - SVG support
- `fl_chart`: ^1.1.1 - Charts
- `skeletonizer`: ^2.1.2 - Loading skeletons

**Utilities:**
- `window_manager`: ^0.5.1 - Desktop window management
- `tray_manager`: ^0.5.0 - System tray
- `antlr4`: ^4.13.2 - BBCode parser
- `cookie_jar`: ^4.0.9 - Cookie management
- `path_provider`: ^2.1.5 - File system access

### Page Modules (lib/pages/)

| Module | Files | Description |
|--------|-------|-------------|
| `popular/` | 4 files | Popular anime page - trending content display |
| `timeline/` | 4 files | Timeline page - seasonal anime schedule |
| `collect/` | 4 files | Collection page - user's anime collections |
| `my/` | 4 files | My page - user profile and settings entry |
| `search/` | 4 files | Search page - anime search functionality |
| `video/` | 4 files | Video page - video source selection |
| `info/` | 7 files | Info page - anime detail information |
| `player/` | 7 files | Player page - video playback with danmaku |
| `settings/` | 12 items | Settings page - app configuration sub-modules |
| `download/` | 5 files | Download page - offline download management |
| `history/` | 4 files | History page - watch history |
| `plugin_editor/` | 5 files | Plugin editor - custom rule creation |
| `webdav_editor/` | 3 files | WebDAV editor - sync configuration |
| `about/` | 2 files | About page - app information |
| `error/` | 1 file | Error page - error display |
| `logs/` | 1 file | Logs page - application logs |
| `menu/` | 1 file | Menu page - navigation menu |

**Settings Sub-modules:**
- `danmaku/` - Danmaku settings (5 files)
- `proxy/` - Proxy settings (3 files)
- `player_settings.dart` - Player configuration
- `theme_settings_page.dart` - Theme and appearance
- `interface_settings.dart` - Interface options
- `download_settings.dart` - Download configuration
- `keyboard_settings.dart` - Keyboard shortcuts
- `decoder_settings.dart` - Video decoder settings
- `renderer_settings.dart` - Renderer settings
- `displaymode_settings.dart` - Display mode settings
- `super_resolution_settings.dart` - Anime4K upscaling settings

### Data Models (lib/modules/)

| Module | Files | Description |
|--------|-------|-------------|
| `bangumi/` | 6 files | Bangumi anime data models |
| `collect/` | 5 files | Collection data models (CollectedBangumi, etc.) |
| `history/` | 2 files | Watch history models |
| `danmaku/` | 3 files | Danmaku data models |
| `download/` | 2 files | Download record models |
| `search/` | 3 files | Search history models |
| `comments/` | 2 files | Comment data models |
| `character/` | 1 file | Character data models |
| `characters/` | 3 files | Characters list models |
| `staff/` | 2 files | Staff information models |
| `roads/` | 1 file | Episode/chapter road models |
| `plugin/` | 1 file | Plugin data models |

### UI Components (lib/bean/)

| Category | Files | Description |
|----------|-------|-------------|
| `card/` | 11 files | Card widgets (anime cards, episode cards, etc.) |
| `appbar/` | 3 files | Custom app bar components |
| `dialog/` | 1 file | Dialog widgets |
| `settings/` | 2 files | Settings UI components |
| `widget/` | 5 files | General utility widgets |

### Plugin System (lib/plugins/)

| File | Description |
|------|-------------|
| `plugins.dart` | Core plugin engine - XPath rule execution |
| `plugins_controller.dart` | Plugin state management (MobX) |
| `plugin_cookie_manager.dart` | Cookie management for plugins |
| `anti_crawler_config.dart` | Anti-crawler configuration |
| `plugin_validity_tracker.dart` | Plugin validity tracking |
| `plugin_install_time_tracker.dart` | Plugin installation tracking |

### Providers (lib/providers/)

| Module | Files | Description |
|--------|-------|-------------|
| `video/` | 3 files | Video source resolution providers |
| `captcha/` | 1 file | Captcha handling providers |

### Repositories (lib/repositories/)

| File | Description |
|------|-------------|
| `collect_repository.dart` | Collection data access |
| `collect_crud_repository.dart` | Collection CRUD operations |
| `history_repository.dart` | History data access |
| `download_repository.dart` | Download data access |
| `search_history_repository.dart` | Search history data access |

### Network Layer (lib/request/)

| File | Description |
|------|-------------|
| `request.dart` | Dio HTTP client configuration |
| `bangumi.dart` | Bangumi API client |
| `damaku.dart` | DanDanPlay API client |
| `api.dart` | API endpoints configuration |
| `interceptor.dart` | HTTP interceptors |
| `query_manager.dart` | Query management |
| `plugin.dart` | Plugin network requests |

### Utilities (lib/utils/)

| File | Description |
|------|-------------|
| `storage.dart` | Local storage utilities |
| `download_manager.dart` | Download management |
| `m3u8_parser.dart` | M3U8 playlist parser |
| `m3u8_ad_filter.dart` | M3U8 ad filtering |
| `webdav.dart` | WebDAV synchronization |
| `syncplay.dart` | SyncPlay protocol implementation |
| `auto_updater.dart` | Auto-update functionality |
| `audio_controller.dart` | Audio playback control |
| `background_download_service.dart` | Background download service |
| `timed_shutdown_service.dart` | Scheduled shutdown |
| `pip_utils.dart` | Picture-in-picture utilities |
| `proxy_utils.dart` / `proxy_manager.dart` | Proxy configuration |
| `anime_season.dart` | Anime season utilities |
| `search_parser.dart` | Search result parsing |
| `string_match.dart` | String matching utilities |
| `format_utils.dart` | Format utilities |
| `external_player.dart` | External player integration |
| `remote.dart` | Remote control functionality |
| `windows_shortcut.dart` | Windows keyboard shortcuts |
| `utils.dart` | General utilities |
| `constants.dart` | App constants |
| `logger.dart` | Logging utilities |
| `extension.dart` | Dart extensions |
| `mortis.dart` | Mortis utilities |

### WebView (lib/webview/)

| Module | Files | Description |
|--------|-------|-------------|
| `video/` | 2 files | Video parsing WebView implementations |
| `captcha/` | 2 files | Captcha handling WebView |

### BBCode Parser (lib/bbcode/)

| File | Description |
|------|-------------|
| `bbcode_base_listener.dart` | Base BBCode listener |
| `bbcode_elements.dart` | BBCode element definitions |
| `bbcode_widget.dart` | BBCode rendering widget |
| `generated/` | 4 files | ANTLR4 generated parser files |

### Shaders (lib/shaders/)

| File | Description |
|------|-------------|
| `shaders_controller.dart` | Anime4K shader controller (MobX) |

## Build & Commands

```bash
# Development
flutter run                                    # Run in debug mode
flutter run -d windows                         # Run on specific platform

# Build release
flutter build apk                              # Android APK (split by ABI)
flutter build windows                          # Windows
flutter build macos                            # macOS
flutter build ios                              # iOS

# Code generation (required after modifying MobX stores or Hive models)
dart run build_runner build --delete-conflicting-outputs

# Testing
flutter test                                   # Run all tests (currently only M3U8 parser test)

# Clean & rebuild
flutter clean && flutter pub get
```

## Architecture Details

### State Management
- **MobX** (`mobx` + `flutter_mobx` + `mobx_codegen`): Primary state management for Controllers. All `.g.dart` files are MobX generated.
- **Provider** (`ChangeNotifier`): Used only for `ThemeProvider` and `NavigationBarState`.

### Routing & DI
- **flutter_modular**: `AppModule` → `IndexModule` → feature modules. All singleton bindings registered in `IndexModule.binds()`.
- Main tabs: `/popular`, `/timeline`, `/collect`, `/my` (defined in `lib/pages/router.dart`).
- Sub-routes: `/video`, `/info`, `/settings`, `/search`.

### Data Persistence
- **Hive CE** (`hive_ce` + `hive_ce_flutter`): Community edition replacing discontinued `hive`. All models use `@HiveType` annotations with generated adapters.
- Key TypeIds: BangumiItem=0, History=1, Progress=2, CollectedBangumi=3, DownloadRecord=7, DownloadEpisode=8.

### Plugin System
The plugin/rule engine (`lib/plugins/`) is the app's core. Each `Plugin` defines:
- Search URL patterns with XPath selectors (`searchList`, `searchName`, `searchResult`)
- Chapter/episode road extraction rules (`chapterRoads`, `chapterResult`)
- Anti-crawler configuration, cookie handling, WebView usage flags
- Key methods: `queryBangumi()` (search), `querychapterRoads()` (get episodes)

### Video Playback
- **media-kit** (forked at `Predidit/media-kit`): Core video player with custom patches for non-standard streams.
- **canvas_danmaku**: Danmaku (bullet comments) rendering engine.
- **Anime4K**: Real-time video upscaling via GLSL shaders (quality/efficiency modes).

### Cross-Platform WebView
Different WebView implementations per platform:
- Android/iOS/macOS: `flutter_inappwebview`
- Windows: `webview_windows` (git dependency)
- Linux: `desktop_webview_window` (git dependency)

### WebDAV Sync
Cross-device sync of collections and history via WebDAV, using change logs (`CollectedBangumiChange`) for incremental sync.

## Build Configuration

### Android (`android/app/build.gradle`)
- applicationId: `com.predidit.kazumi`
- compileSdk: `flutter.compileSdkVersion` (Flutter 3.41.x → 36)
- ndkVersion: `28.2.13676358`
- Java/Kotlin target: 17
- ABI split APKs: armeabi-v7a(1), arm64-v8a(2), x86_64(4), versionCode encodes ABI
- Release signing: debug keys (not production-signed)

### AGP & Kotlin (`android/settings.gradle`)
- AGP: 8.9.1, Kotlin: 2.1.0

### CI/CD (GitHub Actions)
- **release.yaml**: Triggered on tag push. Builds all platforms. Windows uses SignPath for code signing. Injects DanDanPlay API credentials from Secrets.
- **pr.yaml**: PR validation with platform-specific builds using path filters. Draft PRs skip builds.

## Code Style

- Lint rules: `package:flutter_lints/flutter.yaml` (standard Flutter rules, no custom rules)
- Excluded from analysis: `build/**`, `fastlane/**`
- MobX code generation: Controllers use `@observable` and `@action` annotations, `.g.dart` files are generated
- Hive models: Use `@HiveType` and `@HiveField` annotations, adapters generated by `hive_ce_generator`

## Testing

- **Framework**: Flutter test (`flutter test`)
- **Coverage**: Extremely low. Only `test/m3u8_parser_test.dart` has substantive tests (7 scenarios for M3U8 playlist parsing).
- Core business logic (plugin engine, video parsing, data sync, etc.) has **no test coverage**.
- When adding tests, focus on: plugin rule parsing, M3U8 parsing, WebDAV sync logic, repository operations.

## Security Considerations

- **API credentials**: DanDanPlay API keys are injected at build time via GitHub Secrets (placeholder replacement in source). Never commit real credentials.
- **Plugin rules**: User-supplied XPath rules execute against HTML content. Rules from untrusted sources could target unexpected content.
- **WebView**: Used for video source parsing and captcha handling. Be cautious with JavaScript injection and cookie handling.
- **WebDAV**: Credentials stored locally via Hive. Ensure secure storage practices.
- **Release signing**: Android APK currently uses debug keys - production releases need proper signing configuration.
- **Network**: Dio HTTP client with interceptors. Proxy support is configurable. Be mindful of certificate validation.

## Configuration

- **Environment**: No `.env` files. API keys are build-time replacements via CI.
- **local.properties**: Must contain `sdk.dir` (Android SDK path) and `flutter.sdk` (Flutter SDK path).
- **Proxy**: Configurable in app settings, applied to Dio client.
- **Hive boxes**: Initialized in `lib/main.dart` with `Hive.initFlutter()`.
- **MediaKit**: Initialized in `lib/main.dart` with platform-specific configuration.
- **Window management**: Desktop platforms use `window_manager` and `tray_manager` for window behavior and system tray.
