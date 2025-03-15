import 'package:flutter/material.dart';

import 'camera_widget.dart';
import 'enums.dart';

/// A configuration class for camera settings.
///
/// This class simplifies passing multiple camera-related parameters.
class CameraConfig {
  /// Constructor with default values.
  const CameraConfig({
    this.imageResolution = ImageResolution.medium,
    this.defaultCameraType = CameraType.front,
    this.defaultFlashType = CameraFlashType.off,
    this.showControls = true,
    this.showCaptureControl = true,
    this.showFlashControl = true,
    this.showCameraTypeControl = true,
    this.showCloseControl = true,
    this.captureControlIcon,
    this.typeControlIcon,
    this.flashControlBuilder,
    this.closeControlIcon,
    this.cameraPreviewSize = CameraPreviewSize.fill,
    this.minAvailableZoom = 1.0,
    this.maxAvailableZoom = 1.0,
    this.focusColor = Colors.white,
  });

  /// The resolution of the captured image.
  final ImageResolution imageResolution;

  /// The default camera type (front or back).
  final CameraType defaultCameraType;

  /// The default flash setting.
  final CameraFlashType defaultFlashType;

  /// Whether to show camera control buttons.
  final bool showControls;

  /// Whether to show the capture button.
  final bool showCaptureControl;

  /// Whether to show the flash toggle button.
  final bool showFlashControl;

  /// Whether to show the camera switch button.
  final bool showCameraTypeControl;

  /// Whether to show the close button.
  final bool showCloseControl;

  /// Custom widget for the capture button.
  final Widget? captureControlIcon;

  /// Custom widget for the camera switch button.
  final Widget? typeControlIcon;

  /// Custom builder for the flash control button.
  final FlashControlBuilder? flashControlBuilder;

  /// Custom widget for the close button.
  final Widget? closeControlIcon;

  /// Scaling option for the camera preview.
  final CameraPreviewSize cameraPreviewSize;

  /// The minimum zoom level available for the camera.
  final double? minAvailableZoom;

  /// The maximum zoom level available for the camera.
  final double? maxAvailableZoom;

  /// The color of the focus indicator.
  final Color? focusColor;
}
