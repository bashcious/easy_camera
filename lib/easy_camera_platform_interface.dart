import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'easy_camera_method_channel.dart';

abstract class EasyCameraPlatform extends PlatformInterface {
  /// Constructs a EasyCameraPlatform.
  EasyCameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static EasyCameraPlatform _instance = MethodChannelEasyCamera();

  /// The default instance of [EasyCameraPlatform] to use.
  ///
  /// Defaults to [MethodChannelEasyCamera].
  static EasyCameraPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EasyCameraPlatform] when
  /// they register themselves.
  static set instance(EasyCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
