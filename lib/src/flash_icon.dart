import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class CameraFlashIcon extends StatefulWidget {
  const CameraFlashIcon({
    super.key,
    required this.onTap,
    required this.flashIcon,
    this.flashControlBuilder,
  });

  final void Function()? onTap;
  final IconData flashIcon;
  final Widget? flashControlBuilder;

  @override
  State<CameraFlashIcon> createState() => _CameraFlashIconState();
}

class _CameraFlashIconState extends State<CameraFlashIcon> {
  double _targetRotationAngle = 0;
  double _currentRotationAngle = 0;

  double _getRotationAngle(NativeDeviceOrientation orientation) {
    return switch (orientation) {
      NativeDeviceOrientation.landscapeLeft => math.pi / 2, // Rotate +90 degrees
      NativeDeviceOrientation.landscapeRight => -math.pi / 2, // Rotate -90 degrees
      NativeDeviceOrientation.portraitDown => math.pi, // Upside down
      (NativeDeviceOrientation.portraitUp || NativeDeviceOrientation.unknown) =>
        0, // Default portrait
    };
  }

  void _updateRotationAngle(double newAngle) {
    setState(() {
      _targetRotationAngle = newAngle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (BuildContext context) {
        final NativeDeviceOrientation orientation = NativeDeviceOrientationReader.orientation(
          context,
        );
        final double newAngle = _getRotationAngle(orientation);

        if (_targetRotationAngle != newAngle) {
          Future<dynamic>.delayed(const Duration(milliseconds: 300), () {
            _updateRotationAngle(newAngle);
          });
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: 60,
            height: 60,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: _currentRotationAngle, end: _targetRotationAngle),
              duration: const Duration(milliseconds: 500), // Smooth animation duration
              curve: Curves.easeOut,
              onEnd: () {
                _currentRotationAngle = _targetRotationAngle; // Store the final angle
              },
              builder: (BuildContext context, double angle, Widget? child) {
                return Transform.rotate(angle: angle, child: child);
              },
              child:
                  widget.flashControlBuilder ??
                  ClipOval(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(widget.flashIcon, color: Colors.white),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }
}
