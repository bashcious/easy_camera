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
    this.showCaptureIcon = true,
    this.showFlashControl = true,
    this.showCameraSwitchIcon = true,
    this.showCloseIcon = true,
    this.captureIcon,
    this.cameraSwitchIcon,
    this.flashControlBuilder,
    this.closeIcon,
    this.titleWidget,
    this.cameraPreviewSize = CameraPreviewSize.fill,
    this.minAvailableZoom = 1.0,
    this.maxAvailableZoom = 1.0,
    this.focusColor = Colors.white,
    this.showImagePreview = true,
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
  final bool showCaptureIcon;

  /// Whether to show the flash toggle button.
  final bool showFlashControl;

  /// Whether to show the camera switch button.
  final bool showCameraSwitchIcon;

  /// Whether to show the close button.
  final bool showCloseIcon;

  /// Custom widget for the capture button.
  final Widget? captureIcon;

  /// Custom widget for the camera switch button.
  final Widget? cameraSwitchIcon;

  /// Custom builder for the flash control button.
  final FlashControlBuilder? flashControlBuilder;

  /// Custom widget for the close button.
  final Widget? closeIcon;

  /// Custom widget for the title.
  final Widget? titleWidget;

  /// Scaling option for the camera preview.
  final CameraPreviewSize cameraPreviewSize;

  /// The minimum zoom level available for the camera.
  final double? minAvailableZoom;

  /// The maximum zoom level available for the camera.
  final double? maxAvailableZoom;

  /// The color of the focus indicator.
  final Color? focusColor;

  /// Whether to show the captured image preview.
  final bool showImagePreview;
}
