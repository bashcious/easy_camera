import 'package:flutter/material.dart';

import 'easy_camera.dart';

void logError(String message, [String? code]) {
  if (!EasyCamera.printLogs) {
    return;
  }
  if (code != null) {
    debugPrint('Error: $code\nError Message: $message');
  } else {
    debugPrint('Error: $code');
  }
}
