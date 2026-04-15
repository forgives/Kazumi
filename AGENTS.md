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
