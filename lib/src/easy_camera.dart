import 'dart:async';

import 'package:camera/camera.dart';

/// A utility class for managing camera operations in a Flutter app.
import 'package:flutter/material.dart';

import 'camera_config.dart';
import 'camera_widget.dart';
import 'logger.dart';

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
      logError(e.code, e.description);
    }
  }

  /// Returns the list of available cameras.
  static List<CameraDescription> get cameras => _cameras;

  /// Returns whether debug logging is enabled.
  static bool get printLogs => _printLogs;

  /// Wraps `EasyCameraWidget` inside a `Scaffold`
  static Widget cameraView({
    required CameraConfig config,
    required void Function(XFile?) onCapture,
  }) {
    return EasyCameraWidget(config: config, onCapture: onCapture);
  }
}
