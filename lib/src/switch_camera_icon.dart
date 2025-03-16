import 'package:flutter/material.dart';

class SwitchCameraIcon extends StatefulWidget {
  const SwitchCameraIcon({super.key, required this.onTap, this.switchCameraIcon});
  final void Function()? onTap;
  final Widget? switchCameraIcon;

  @override
  State createState() => _RotatingIconButtonState();
}

class _RotatingIconButtonState extends State<SwitchCameraIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false; // Prevents multiple taps

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Animation duration
    );

    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false; // Enable tap after animation completes
        });
      }
    });
  }

  void _animateRotation() {
    if (_isAnimating) {
      return; // Prevent double tap
    }

    setState(() {
      _isAnimating = true; // Disable further taps
    });

    _controller.forward(from: 0.0); // Restart animation
    widget.onTap?.call(); // Call the camera switch function
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            return Transform.rotate(
              angle: _controller.value * 2 * 3.1416, // Full rotation
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
        ),
      ),
    );
  }
}
