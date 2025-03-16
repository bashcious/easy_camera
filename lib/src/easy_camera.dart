import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_config.dart';
import 'camera_widget.dart';
import 'logger.dart';

/// A utility class for managing camera operations in a Flutter app.
class EasyCamera {
  /// A list of available cameras on the device.
  static List<CameraDescription> _cameras = <CameraDescription>[];

  /// Flag to enable or disable debug logs.
  static bool _printLogs = false;

  /// Initializes the camera by fetching the list of available cameras.
  ///
  /// - [printLogs]: If true, debug logs will be printed.
  static Future<void> initialize({bool printLogs = false}) async {
    try {
      _cameras = await availableCameras();
      _printLogs = printLogs;
    } on CameraException catch (e) {
      // Logs error if camera initialization fails.
      logError(e.code, e.description);
    }
  }

  /// Returns the list of available cameras.
  static List<CameraDescription> get cameras => _cameras;

  /// Returns whether debug logging is enabled.
  static bool get printLogs => _printLogs;

  /// Opens a camera dialog to capture an image and returns the captured file.
  ///
  /// - [context]: The [BuildContext] needed to display the camera.
  /// - [config]: The configuration settings for the camera.
  ///
  /// Returns an [XFile] containing the captured image, or `null` if the user cancels.
  static Future<XFile?> capturePhoto(BuildContext context, CameraConfig config) async {
    XFile? cameraFile;

    // Displays the camera UI inside a dialog.
    await showDialog<dynamic>(
      barrierColor: Colors.black,
      context: context,
      builder: (BuildContext context) {
        return CameraWidget(
          imageResolution: config.imageResolution,
          defaultCameraType: config.defaultCameraType,
          defaultFlashType: config.defaultFlashType,
          showControls: config.showControls,
          showCaptureControl: config.showCaptureControl,
          showFlashControl: config.showFlashControl,
          showCameraTypeControl: config.showCameraTypeControl,
          showCloseControl: config.showCloseControl,
          onCapture: (XFile? file) {
            cameraFile = file;
            Navigator.pop(context);
          },
          captureControlIcon: config.captureControlIcon,
          switchCameraIcon: config.typeControlIcon,
          flashControlBuilder: config.flashControlBuilder,
          closeControlIcon: config.closeControlIcon,
          cameraPreviewSize: config.cameraPreviewSize,
          minAvailableZoom: config.minAvailableZoom,
          maxAvailableZoom: config.maxAvailableZoom,
          focusColor: config.focusColor,
          showImagePreview: config.showImagePreview,
        );
      },
    );

    return cameraFile;
  }
}
