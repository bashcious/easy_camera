
import 'easy_camera_platform_interface.dart';

class EasyCamera {
  Future<String?> getPlatformVersion() {
    return EasyCameraPlatform.instance.getPlatformVersion();
  }
}
