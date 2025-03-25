import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  final Future<ImageProvider<Object>?> image;
  final BoxFit fit;
  final double width;
  final double height;

  @override
  State createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  NativeDeviceOrientation _initialOrientation = NativeDeviceOrientation.unknown;
  NativeDeviceOrientation _currentOrientation = NativeDeviceOrientation.unknown;
  Timer? _debounceTimer; // Timer for debounce

  @override
  void initState() {
    super.initState();
    _getInitialOrientation();
  }

  Future<void> _getInitialOrientation() async {
    final NativeDeviceOrientation orientation =
        await NativeDeviceOrientationCommunicator().orientation(
          useSensor: true,
        );

        

    if (mounted) {
      // Prevent calling setState on an unmounted widget
      setState(() {
        _initialOrientation = orientation;
        _currentOrientation = orientation;
      });
    }

    _listenToOrientationChanges();
  }

  void _listenToOrientationChanges() {
    NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen((NativeDeviceOrientation orientation) {
          if (_debounceTimer?.isActive ?? false) {
            _debounceTimer!.cancel(); // Cancel previous timer
          }

          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Check if widget is still in the tree
              setState(() {
                _currentOrientation = orientation;
              });
            }
          });
        });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Cleanup timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double rotationAngle = 0;

    // If initial orientation was landscape, keep rotation 0
    final bool isInitialLandscape =
        _initialOrientation == NativeDeviceOrientation.landscapeLeft ||
        _initialOrientation == NativeDeviceOrientation.landscapeRight;

    // If user rotates after initial load, apply rotation
    if (isInitialLandscape) {
      if (_currentOrientation == NativeDeviceOrientation.portraitUp) {
        rotationAngle = -1.5708; // Rotate -90 degrees to portrait
      } else if (_currentOrientation == NativeDeviceOrientation.portraitDown) {
        rotationAngle = 1.5708; // Rotate 90 degrees to portrait
      }
    } else {
      // Initial orientation was portrait, rotate if switched to landscape
      if (_currentOrientation == NativeDeviceOrientation.landscapeLeft) {
        rotationAngle = 1.5708; // Rotate 90 degrees to landscape
      } else if (_currentOrientation ==
          NativeDeviceOrientation.landscapeRight) {
        rotationAngle = -1.5708; // Rotate -90 degrees to landscape
      }
    }

    return FutureBuilder<ImageProvider<Object>?>(
      future: widget.image,
      builder: (
        BuildContext context,
        AsyncSnapshot<ImageProvider<Object>?> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Icon(Icons.error));
        } else {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: <Widget>[
                Center(
                  child: Transform.rotate(
                    angle: rotationAngle,
                    child: PhotoViewGallery(
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      loadingBuilder:
                          (BuildContext context, ImageChunkEvent? event) =>
                              const Center(child: CircularProgressIndicator()),
                      pageOptions: <PhotoViewGalleryPageOptions>[
                        PhotoViewGalleryPageOptions(
                          imageProvider: snapshot.data,
                          heroAttributes: const PhotoViewHeroAttributes(
                            tag: 'imageHero',
                          ),
                          minScale: PhotoViewComputedScale.contained,
                          initialScale: PhotoViewComputedScale.contained,
                          basePosition: Alignment.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    iconSize: 35,
                    icon: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.clear,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[CloseIcon(), ConfirmButton()],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class CloseIcon extends StatelessWidget {
  const CloseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(2),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide>((_) {
          return const BorderSide(color: Color(0xffF76659));
        }),
      ),
      child: const Icon(Icons.close, color: Color(0xffF76659)),
    );
  }
}

class ConfirmButton extends StatefulWidget {
  const ConfirmButton({super.key});

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  double _targetRotationAngle = 0;
  double _currentRotationAngle = 0;

  double _getRotationAngle(NativeDeviceOrientation orientation) {
    return switch (orientation) {
      NativeDeviceOrientation.landscapeLeft =>
        math.pi / 2, // Rotate +90 degrees
      NativeDeviceOrientation.landscapeRight =>
        -math.pi / 2, // Rotate -90 degrees
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
        final NativeDeviceOrientation orientation =
            NativeDeviceOrientationReader.orientation(context);

        final double newAngle = _getRotationAngle(orientation);

        if (_targetRotationAngle != newAngle) {
          Future<dynamic>.delayed(const Duration(milliseconds: 300), () {
            _updateRotationAngle(newAngle);
          });
        }

        return OutlinedButton(
          onPressed: () => Navigator.pop(context, true),
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(2),
          ).copyWith(
            side: WidgetStateProperty.resolveWith<BorderSide>((_) {
              return const BorderSide(color: Color(0xffBBFBD0));
            }),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: _currentRotationAngle,
              end: _targetRotationAngle,
            ),
            duration: const Duration(
              milliseconds: 500,
            ), // Smooth animation duration
            curve: Curves.easeOut,
            onEnd: () {
              _currentRotationAngle =
                  _targetRotationAngle; // Store the final angle
            },
            builder: (BuildContext context, double angle, Widget? child) {
              return Transform.rotate(angle: angle, child: child);
            },
            child: const Icon(Icons.check, color: Color(0xffBBFBD0)),
          ),
        );
      },
    );
  }
}
