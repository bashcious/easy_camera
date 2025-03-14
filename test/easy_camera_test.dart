import 'package:flutter_test/flutter_test.dart';
import 'package:easy_camera/easy_camera.dart';
import 'package:easy_camera/easy_camera_platform_interface.dart';
import 'package:easy_camera/easy_camera_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEasyCameraPlatform
    with MockPlatformInterfaceMixin
    implements EasyCameraPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EasyCameraPlatform initialPlatform = EasyCameraPlatform.instance;

  test('$MethodChannelEasyCamera is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEasyCamera>());
  });

  test('getPlatformVersion', () async {
    EasyCamera easyCameraPlugin = EasyCamera();
    MockEasyCameraPlatform fakePlatform = MockEasyCameraPlatform();
    EasyCameraPlatform.instance = fakePlatform;

    expect(await easyCameraPlugin.getPlatformVersion(), '42');
  });
}
