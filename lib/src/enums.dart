import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

enum ImageResolution {
   /// 352x288 on iOS, 240p (320x240) on Android and Web
  low,

  /// 480p (640x480 on iOS, 720x480 on Android and Web)
  medium,

  /// 720p (1280x720)
  high,

  /// 1080p (1920x1080)
  veryHigh,

  /// 2160p (3840x2160 on Android and iOS, 4096x2160 on Web)
  ultraHigh,

  /// The highest resolution available.
  max,
}

extension ImageResolutionExtension on ImageResolution {
  ResolutionPreset get resolutionPreset {
    switch (this) {
      case ImageResolution.low:
        return ResolutionPreset.low;
      case ImageResolution.medium:
        return ResolutionPreset.medium;
      case ImageResolution.high:
        return ResolutionPreset.high;
      case ImageResolution.veryHigh:
        return ResolutionPreset.veryHigh;
      case ImageResolution.ultraHigh:
        return ResolutionPreset.ultraHigh;
      case ImageResolution.max:
        return ResolutionPreset.max;
    }
  }
}

enum CameraType {
  /// Front facing camera (a user looking at the screen is seen by the camera).
  front,

  /// Back facing camera (a user looking at the screen is not seen by the camera).
  back,

  /// External camera which may not be mounted to the device.
  external,
}

extension CameraTypeExtension on CameraType {
  CameraLensDirection? get cameraLensDirection {
    return switch (this) {
      CameraType.front => CameraLensDirection.front,
      CameraType.back => CameraLensDirection.back,
      CameraType.external => CameraLensDirection.external,
    };
  }
}

extension CameraLensDirectionExtension on CameraLensDirection {
  CameraType? get cameraType {
    return switch (this) {
      CameraLensDirection.front => CameraType.front,
      CameraLensDirection.back => CameraType.back,
      CameraLensDirection.external => CameraType.external,
    };
  }
}

/// The possible flash modes that can be set for a camera
enum CameraFlashType {
  /// Do not use the flash when taking a picture.
  off,

  /// Let the device decide whether to flash the camera when taking a picture.
  auto,

  /// Always use the flash when taking a picture.
  always,
}

extension CameraFlashTypeExtension on CameraFlashType {
  FlashMode get flashMode {
    return switch (this) {
      CameraFlashType.off => FlashMode.off,
      CameraFlashType.auto => FlashMode.auto,
      CameraFlashType.always => FlashMode.always,
    };
  }
}

enum CameraOrientation {
  /// If the device shows its boot logo in portrait, then the boot logo is shown
  /// in [portraitUp]. Otherwise, the device shows its boot logo in landscape
  /// and this orientation is obtained by rotating the device 90 degrees
  /// clockwise from its boot orientation.
  portraitUp,

  /// The orientation that is 90 degrees clockwise from [portraitUp].
  ///
  /// If the device shows its boot logo in landscape, then the boot logo is
  /// shown in [landscapeLeft].
  landscapeLeft,

  /// The orientation that is 180 degrees from [portraitUp].
  portraitDown,

  /// The orientation that is 90 degrees counterclockwise from [portraitUp].
  landscapeRight,
}

enum ImageScale {
  none,

  /// 16:9
  small,

  /// 1:1
  middle,

  /// 3:4
  big,
}

extension ImageScaleExtension on ImageScale {
  double get scale {
    return switch (this) {
      ImageScale.small => 16 / 9,
      ImageScale.middle => 1 / 1,
      ImageScale.big => 4 / 5,
      ImageScale.none => 0,
    };
  }
}

extension CameraOrientationExtension on CameraOrientation {
  DeviceOrientation? get deviceOrientation {
    return switch (this) {
      CameraOrientation.portraitUp => DeviceOrientation.portraitUp,
      CameraOrientation.landscapeLeft => DeviceOrientation.landscapeLeft,
      CameraOrientation.portraitDown => DeviceOrientation.portraitDown,
      CameraOrientation.landscapeRight => DeviceOrientation.landscapeRight,
    };
  }
}
