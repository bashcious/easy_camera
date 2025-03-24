import 'package:flutter_easy_camera/easy_camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key, required this.config});
  final CameraConfig config;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: EasyCamera.cameraView(
        config: config,
        onCapture: (XFile? file) async {
          if (file != null) {
            if (context.mounted) {
              Navigator.pop(context, file);
            }
          }
        },
      ),
    );
  }
}