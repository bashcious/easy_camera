import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'easy_camera_platform_interface.dart';

/// An implementation of [EasyCameraPlatform] that uses method channels.
class MethodChannelEasyCamera extends EasyCameraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('easy_camera');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
