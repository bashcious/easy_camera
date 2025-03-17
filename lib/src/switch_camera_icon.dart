import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class CameraSwitchIcon extends StatefulWidget {
  const CameraSwitchIcon({super.key, required this.onTap, this.switchCameraIcon});

  final VoidCallback? onTap;
  final Widget? switchCameraIcon;

  @override
  State<CameraSwitchIcon> createState() => _CameraSwitchIconState();
}

class _CameraSwitchIconState extends State<CameraSwitchIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;
  double _targetRotationAngle = 0;
  double _currentRotationAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
      }
    });
  }

  void _animateRotation() {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

        // If orientation changes, animate to new angle
        if (_targetRotationAngle != newAngle) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _updateRotationAngle(newAngle);
          });
        }

        return GestureDetector(
          onTap: _animateRotation,
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: _currentRotationAngle, end: _targetRotationAngle),
                  duration: const Duration(milliseconds: 500), // Smooth transition
                  curve: Curves.easeOut,
                  onEnd: () {
                    _currentRotationAngle = _targetRotationAngle;
                  },
                  builder: (BuildContext context, double angle, Widget? child) {
                    return Transform.rotate(
                      angle: (_controller.value * 2 * math.pi) + angle,
                      child: child,
                    );
                  },
                  child:
                      widget.switchCameraIcon ??
                      ClipOval(
                        child: ColoredBox(
                          color: Colors.black.withOpacity(0.3),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(Icons.cameraswitch_outlined, color: Colors.white),
                          ),
                        ),
                      ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
