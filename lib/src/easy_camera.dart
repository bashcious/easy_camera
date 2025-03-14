import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_widget.dart';
import 'enums.dart';
import 'logger.dart';

class EasyCamera {
  static List<CameraDescription> _cameras = <CameraDescription>[];

  static bool _printLogs = false;

  static Future<void> initialize({bool printLogs = false}) async {
    try {
      _cameras = await availableCameras();
      _printLogs = printLogs;
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }

  static List<CameraDescription> get cameras {
    return _cameras;
  }

  static bool get printLogs {
    return _printLogs;
  }

  static Future<XFile?> selfieCameraFile(
    BuildContext context, {
    ImageResolution imageResolution = ImageResolution.medium,
    CameraType defaultCameraType = CameraType.front,
    CameraFlashType defaultFlashType = CameraFlashType.off,
    CameraOrientation? orientation,
    bool showControls = true,
    bool showCaptureControl = true,
    bool showFlashControl = true,
    bool showCameraTypeControl = true,
    bool showCloseControl = true,
    Widget? captureControlIcon,
    Widget? typeControlIcon,
    FlashControlBuilder? flashControlBuilder,
    Widget? closeControlIcon,
    ImageScale imageScale = ImageScale.none,
  }) async {
    XFile? cameraFile;
    await showDialog<dynamic>(
      barrierColor: Colors.black,
      context: context,
      builder: (BuildContext context) {
        return CameraWidget(
          imageResolution: imageResolution,
          defaultCameraType: defaultCameraType,
          defaultFlashType: defaultFlashType,
          orientation: orientation,
          showControls: showControls,
          showCaptureControl: showCaptureControl,
          showFlashControl: showFlashControl,
          showCameraTypeControl: showCameraTypeControl,
          showCloseControl: showCloseControl,
          onCapture: (XFile? file) {
            cameraFile = file;
            Navigator.pop(context);
          },
          captureControlIcon: captureControlIcon,
          typeControlIcon: typeControlIcon,
          flashControlBuilder: flashControlBuilder,
          closeControlIcon: closeControlIcon,
          imageScale: imageScale,
        );
      },
    );
    return cameraFile;
  }
}
