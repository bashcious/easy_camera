import 'dart:async';

import 'package:flutter/material.dart';

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
  Timer? _rotationTimer;

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 60,
        height: 60,
        child:
            widget.flashControlBuilder ??
            ClipOval(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(2.0),
                child: Icon(widget.flashIcon, color: Colors.white),
              ),
            ),
      ),
    );
  }
}
