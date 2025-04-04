# Changelog

## [0.0.7] - 2025-04-04
### Changed
- Converted package from a Flutter plugin to a normal Dart package.
- Removed unused native code for Android and iOS.
- Updated `pubspec.yaml` to remove unnecessary platform dependencies.
- Cleaned up project structure by deleting `android/`, `ios/`, `macos/`, `windows/`, and `linux/` directories.
- Updated README to reflect changes and clarify package scope.

### Fixed
- Avoids unnecessary native compilation and linking, reducing app build size and maintenance effort.

## [0.0.1] - 2025-03-28
### Added
- Initial release of `flutter_easy_camera` package.
- Basic camera preview wrapper and image capture functionality.
- Customizable camera settings (flash, camera switch, resolution, etc.).

