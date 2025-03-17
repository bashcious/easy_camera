import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';

import 'camera_config.dart';
import 'easy_camera.dart';
import 'enums.dart';
import 'image_viewer.dart';
import 'logger.dart';
import 'switch_camera_icon.dart';
import 'take_photo_button.dart';

typedef FlashControlBuilder = Widget Function(BuildContext context, CameraFlashType mode);

/// A customizable camera widget that provides an interface for capturing images
/// with various configurations such as resolution, camera type, flash control,
/// zoom levels, and UI controls.
///
/// This widget supports switching between front and rear cameras, adjusting zoom levels,
/// enabling/disabling UI controls, and handling image captures through a callback.
///
/// ### Features:
/// - Customizable camera resolution.
/// - Supports front and rear camera selection.
/// - Adjustable zoom levels with `minAvailableZoom` and `maxAvailableZoom`.
/// - Flash mode control (on, off, auto).
/// - Orientation locking (portrait, landscape).
/// - Optional UI controls for capture, flash, camera switch, and closing the camera view.
/// - Image scaling options.
///
/// The captured image can be retrieved via the [onCapture] callback.
///
/// Example Usage:
/// ```dart
/// EasyCameraWidget(
///   defaultCameraType: CameraType.rear,
///   showFlashControl: true,
///   minAvailableZoom: 1.0,
///   maxAvailableZoom: 4.0,
///   onCapture: (XFile? image) {
///     if (image != null) {
///       print("Captured image path: ${image.path}");
///     }
///   },
/// )
/// ```
class EasyCameraWidget extends StatefulWidget {
  const EasyCameraWidget({super.key, required this.config, required this.onCapture});

  final CameraConfig config;
  final void Function(XFile?)? onCapture;

  @override
  State<EasyCameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<EasyCameraWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  /// A key to uniquely identify the CameraWidget.
  final GlobalKey _cameraWidgetKey = GlobalKey();

  /// Tracks whether the capture button is clicked.
  bool _isClick = false;

  /// Tracks whether the app is running in the background.
  bool _isAppInBackground = false;

  /// The camera controller responsible for handling the camera preview and capturing images.
  CameraController? _controller;

  /// The current flash mode index.
  int _currentFlashMode = 0;

  /// List of available flash modes (Off, Auto, Always On).
  final List<CameraFlashType> _availableFlashMode = <CameraFlashType>[
    CameraFlashType.off,
    CameraFlashType.auto,
    CameraFlashType.always,
  ];

  /// The current camera type index (Front/Rear).
  int _currentCameraType = 0;

  /// List of available camera types (Front, Rear).
  final List<CameraType> _availableCameraType = <CameraType>[];

  /// The current zoom scale of the camera.
  double _currentScale = 1.0;

  /// The base scale used for pinch-to-zoom functionality.
  double _baseScale = 1.0;

  /// Number of fingers detected on the screen.
  int _pointers = 0;

  /// The fixed size of the autofocus frame indicator.
  static const double _autoFocusFrameSize = 80;

  /// The minimum zoom level available for the camera.
  double? _minAvailableZoom;

  /// The maximum zoom level available for the camera.
  double? _maxAvailableZoom;

  /// Notifier to track the focus frame position on the camera preview.
  ValueNotifier<Offset>? _focusFrame;

  /// Animation for focus indicator opacity.
  Animation<double>? opacityTween;

  /// Animation for focus indicator thickness.
  Animation<double>? thicknessTween;

  /// Controller for handling focus indicator animations.
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();

    // Lock screen orientation to portrait
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    /// Observes app lifecycle changes (e.g., background/foreground state).
    WidgetsBinding.instance.addObserver(this);

    /// Sets the minimum and maximum available zoom levels from widget properties.
    _minAvailableZoom = widget.config.minAvailableZoom;
    _maxAvailableZoom = widget.config.maxAvailableZoom;

    /// Initializes the focus frame position as an infinite offset.
    _focusFrame = ValueNotifier<Offset>(Offset.infinite);

    /// Initializes the animation controller for focus animations.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    /// Creates an opacity animation for the focus indicator, fading out with a bounce effect.
    opacityTween = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.bounceOut));

    /// Creates an animation for the focus indicator thickness, shrinking smoothly.
    thicknessTween = Tween<double>(
      begin: 3.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.bounceInOut));

    /// Fetches all available camera types (e.g., front/rear).
    _getAllAvailableCameraType();

    /// Initializes the camera controller and sets up the camera.
    _initializeCamera();
  }

  @override
  void dispose() {
    /// Removes this widget from the app lifecycle observer list.
    WidgetsBinding.instance.removeObserver(this);

    // Reset to system default orientations when leaving the screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    /// Disposes resources only if the camera controller is initialized.
    if (_controller?.value.isInitialized ?? false) {
      _focusFrame?.dispose(); // Dispose of the focus frame notifier.
      _animationController?.dispose(); // Dispose of the animation controller.
      _controller?.dispose(); // Dispose of the camera controller.
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// Ensure the camera controller exists and is initialized before proceeding.
    if (_controller?.value.isInitialized != true) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      /// App is going into the background or becoming inactive.
      /// Dispose of the camera resources to free up system resources.
      setState(() => _isAppInBackground = true);
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      /// App is resuming from the background.
      /// Reinitialize the camera to restore functionality.
      _initializeCamera();
      setState(() => _isAppInBackground = false);
    }
  }

  /// Retrieves all available camera types from the device and updates the list.
  void _getAllAvailableCameraType() {
    for (final CameraDescription camera in EasyCamera.cameras) {
      final CameraType? type = camera.lensDirection.cameraType;

      // Add camera type if it's not already in the list
      if (type != null && !_availableCameraType.contains(type)) {
        _availableCameraType.add(type);
      }
    }

    // Set the default camera type index safely
    final int defaultIndex = _availableCameraType.indexOf(widget.config.defaultCameraType);
    _currentCameraType = defaultIndex != -1 ? defaultIndex : 0;
  }

  /// Initializes the camera with the selected lens direction and settings.
  Future<void> _initializeCamera() async {
    // Filter available cameras based on the selected lens direction
    final List<CameraDescription> cameras =
        EasyCamera.cameras
            .where(
              (CameraDescription c) =>
                  c.lensDirection == _availableCameraType[_currentCameraType].cameraLensDirection,
            )
            .toList();

    // Ensure at least one matching camera is found
    if (cameras.isEmpty) {
      return;
    }

    // Create a new CameraController with selected settings
    _controller = CameraController(
      cameras.first,
      widget.config.imageResolution.resolutionPreset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      // Initialize the camera and check if the widget is still mounted
      await _controller!.initialize();
      if (!mounted) {
        return;
      }

      // Fetch the available zoom range
      final List<Future<void>> zoomLevelFutures = <Future<void>>[
        _controller!.getMaxZoomLevel().then((double value) => _maxAvailableZoom = value),
        _controller!.getMinZoomLevel().then((double value) => _minAvailableZoom = value),
      ];
      await Future.wait(zoomLevelFutures);

      // Enable autofocus mode
      await _controller!.setFocusMode(FocusMode.auto);

      // Set the default flash mode
      await _changeFlashMode(_availableFlashMode.indexOf(widget.config.defaultFlashType));

      // Update UI state
      // setState(() {});
    } catch (e) {
      logError('Camera initialization failed: $e');
    }
  }

  /// Changes the camera flash mode based on the provided index.
  Future<void> _changeFlashMode(int index) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      logError('Flash mode change failed: CameraController is not initialized.');
      return;
    }

    try {
      // Set the flash mode using the corresponding mode from the list
      await _controller!.setFlashMode(_availableFlashMode[index].flashMode);

      // Update UI state only if the widget is still mounted
      if (mounted) {
        setState(() => _currentFlashMode = index);
      }
    } catch (e) {
      logError('Failed to change flash mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = _controller;
    final ui.Size screenSize = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body:
            _isAppInBackground
                ? Container(
                  color: Colors.black,
                ) // Show a black screen when app is in the background
                : Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Display the camera preview if the controller is initialized
                    if (cameraController != null &&
                        cameraController.value.isInitialized) ...<Widget>[
                      if (widget.config.cameraPreviewSize == CameraPreviewSize.fill)
                        Transform.scale(
                          scale: 1.0,
                          child: AspectRatio(
                            aspectRatio: screenSize.aspectRatio,
                            child: OverflowBox(
                              child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: SizedBox(
                                  width: screenSize.width,
                                  height: screenSize.width * cameraController.value.aspectRatio,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      _autoFocusAnimationWidget(
                                        camera: _buildCameraView(cameraController),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        _buildCameraPreview(cameraController),
                    ] else
                      Container(color: Colors.black), // Placeholder if the camera is not ready
                    // Camera control buttons (flash, capture, switch camera)
                    if (widget.config.showControls &&
                        widget.config.cameraPreviewSize == CameraPreviewSize.fill) ...<Widget>[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ColoredBox(color: Colors.transparent, child: _controlsWidget()),
                        ),
                      ),
                    ],

                    // Close button (top-left)
                    if (widget.config.showControls &&
                        widget.config.cameraPreviewSize == CameraPreviewSize.fill)
                      Align(alignment: Alignment.topLeft, child: _clearWidget()),
                  ],
                ),
      ),
    );
  }

  /// Builds the camera preview widget with gesture controls for scaling and focusing.
  Widget _buildCameraView(CameraController controller) {
    return Listener(
      /// Tracks the number of active touch points (used for multi-touch gestures).
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,

      child: CameraPreview(
        controller,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,

              /// Handles zoom gesture start
              onScaleStart: _handleScaleStart,

              /// Handles zoom updates when scaling
              onScaleUpdate: _handleScaleUpdate,

              /// Handles focus when the user taps the preview
              onTapDown: (TapDownDetails details) => _onViewFinderTap(details, constraints),

              /// Plays the autofocus animation when tap is released
              onTapUp: _onTapPlayFocusAnimation,
            );
          },
        ),
      ),
    );
  }

  /// Builds the camera preview with proper aspect ratio handling and scaling.
  Widget _buildCameraPreview(CameraController controller) {
    final ui.Size size = MediaQuery.of(context).size;
    final Widget area = ClipRect(
      child: OverflowBox(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: SizedBox(
            width: size.width,
            height: size.width * controller.value.aspectRatio,
            child: Stack(
              children: <Widget>[_autoFocusAnimationWidget(camera: _buildCameraView(controller))],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.config.showControls && widget.config.cameraPreviewSize != CameraPreviewSize.fill)
          _clearWidget(),
        // Camera preview with aspect ratio maintained
        Expanded(
          child: Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: widget.config.cameraPreviewSize.scale,
                child: RepaintBoundary(key: _cameraWidgetKey, child: area),
              ),
            ],
          ),
        ),

        // Camera controls at the bottom
        Container(
          width: double.infinity,
          height: 150,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child:
              (widget.config.showControls &&
                      widget.config.cameraPreviewSize != CameraPreviewSize.fill)
                  ? _controlsWidget()
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _controlsWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 18,
      children: <Widget>[
        // Flash control button (or placeholder if disabled)
        if (widget.config.showFlashControl)
          _buildFlashToggleButton()
        else
          const SizedBox(height: 60, width: 60),

        // Capture button with spacing
        if (widget.config.showCaptureControl) ...<Widget>[
          const SizedBox(width: 20),
          _buildCaptureButton(),
          const SizedBox(width: 20),
        ],

        // Switch camera button (or placeholder if disabled)
        if (widget.config.showCameraTypeControl)
          SwitchCameraIcon(
            onTap:
                _controller?.value.isInitialized ?? false
                    ? () {
                      _currentCameraType = (_currentCameraType + 1) % _availableCameraType.length;

                      _initializeCamera();
                    }
                    : null,
          )
        else
          const SizedBox(height: 60, width: 60),
      ],
    );
  }

  /// Builds the capture button widget.
  Widget _buildCaptureButton() {
    final bool isCameraReady = _controller?.value.isInitialized ?? false;

    return TakePhotoButton(
      key: const ValueKey<String>('takePhotoButton'),
      onTap: isCameraReady ? _onTakePictureButtonPressed : null,
    );
  }

  /// Builds the flash control button.
  Widget _buildFlashToggleButton() {
    if (_controller?.value.isInitialized != true) {
      return const SizedBox(width: 60, height: 60);
    }

    final CameraFlashType currentFlashMode = _availableFlashMode[_currentFlashMode];
    final IconData flashIcon = _getFlashIcon(currentFlashMode);

    return GestureDetector(
      onTap: () => _changeFlashMode((_currentFlashMode + 1) % _availableFlashMode.length),
      child: ColoredBox(
        color: Colors.transparent,
        child: SizedBox(
          width: 60,
          height: 60,
          child:
              widget.config.flashControlBuilder?.call(context, currentFlashMode) ??
              ClipOval(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(flashIcon, color: Colors.white),
                ),
              ),
        ),
      ),
    );
  }

  /// Returns the corresponding flash mode icon.
  IconData _getFlashIcon(CameraFlashType flashType) {
    const Map<CameraFlashType, IconData> flashIcons = <CameraFlashType, IconData>{
      CameraFlashType.always: Icons.flash_on,
      CameraFlashType.off: Icons.flash_off,
      CameraFlashType.auto: Icons.flash_auto,
    };

    return flashIcons[flashType] ?? Icons.flash_auto;
  }

  Widget _clearWidget() {
    return IconButton(
      iconSize: 30,
      icon: widget.config.closeControlIcon ?? _buildCloseIcon(),
      onPressed: () => Navigator.pop(context),
    );
  }

  /// Builds the default close button icon with consistent styling.
  Widget _buildCloseIcon() {
    return CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.05), // Fixed method usage
      child: const Padding(
        padding: EdgeInsets.all(2.0),
        child: Icon(Icons.clear, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> _onTakePictureButtonPressed() async {
    if (_isClick || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    _isClick = true;

    try {
      final CameraController cameraController = _controller!;

      if (cameraController.value.isStreamingImages) {
        await cameraController.stopImageStream();
      }

      final XFile? file = await _takePicture();

      if (file != null && mounted) {
        _isClick = false;
        if (widget.config.showImagePreview) {
          final dynamic result = await Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder:
                  (BuildContext context) =>
                      ImageViewer(image: _fileToImageProvider(File(file.path))),
            ),
          );
          if (result != null && widget.onCapture != null) {
            widget.onCapture!(file);
          }
        } else {
          if (widget.onCapture != null) {
            widget.onCapture!(file);
          }
        }
      }
    } catch (e) {
      logError(e.toString());
    } finally {
      _isClick = false; // Ensure it is reset even if an error occurs
    }
  }

  /// Captures an image using the camera and processes it based on the selected settings.
  Future<XFile?> _takePicture() async {
    // Check if the camera controller is available and initialized.
    if (_controller == null || !_controller!.value.isInitialized) {
      logError('Error: No camera selected or not initialized.');
      return null;
    }

    // Prevent capturing if the camera is already taking a picture.
    if (_controller!.value.isTakingPicture) {
      logError('Error: Camera is already capturing an image.');
      return null;
    }

    try {
      // Capture the image and retrieve the file.
      final XFile file = await _controller!.takePicture();

      // Read the image bytes from the captured file.
      final Uint8List bytes = await file.readAsBytes();

      // If no scaling is required, check if the front camera was used and flip the image.
      if (widget.config.cameraPreviewSize == CameraPreviewSize.fill) {
        if (_controller!.description.lensDirection == CameraLensDirection.front) {
          final ImageEditorOption option = ImageEditorOption();
          option.addOption(const FlipOption()); // Flip the image for front camera shots.

          // Process the image and replace the file with the flipped version.
          final Uint8List? processedBytes = await ImageEditor.editImage(
            image: bytes,
            imageEditorOption: option,
          );
          if (processedBytes != null) {
            await File(file.path).delete(); // Delete the original file.
            await File(file.path).writeAsBytes(processedBytes); // Write the flipped image.
          }
        }
      } else {
        // If scaling is required, crop the image to the specified aspect ratio.
        final ui.Image image = await _convertUint8ListToImage(bytes);
        final double width = image.width.toDouble();
        final double height = image.height.toDouble();
        final double realHeight =
            width / widget.config.cameraPreviewSize.scale; // Calculate new height.
        final double topY = (height - realHeight) / 2; // Center cropping position.

        final ImageEditorOption option = ImageEditorOption();
        option.addOption(ClipOption(y: topY, width: width, height: realHeight)); // Crop image.

        // Flip image if taken from the front camera.
        if (_controller!.description.lensDirection == CameraLensDirection.front) {
          option.addOption(const FlipOption());
        }

        // Process the image and replace the file with the cropped/flipped version.
        final Uint8List? processedBytes = await ImageEditor.editImage(
          image: bytes,
          imageEditorOption: option,
        );

        if (processedBytes != null) {
          await File(file.path).delete(); // Delete the original file.
          await File(file.path).writeAsBytes(processedBytes); // Write the edited image.
        }
      }

      // Return the final processed image file.
      return file;
    } on CameraException catch (e) {
      logError('CameraException: ${e.code}', e.description ?? 'No description available');
      return null;
    } catch (e) {
      logError('Unexpected error while taking picture: $e');
      return null;
    }
  }

  /// Displays an autofocus animation overlay on top of the camera preview.
  /// This widget shows a circular focus indicator at the last focus point and animates it.
  Widget _autoFocusAnimationWidget({required Widget camera}) {
    return Stack(
      children: <Widget>[
        // The main camera preview widget.
        camera,

        // Listens for focus point changes and updates the UI accordingly.
        ValueListenableBuilder<Offset>(
          valueListenable: _focusFrame ?? ValueNotifier<Offset>(Offset.infinite),
          builder: (BuildContext context, ui.Offset offset, Widget? child) {
            // If no focus position is set or animation is unavailable, hide the focus frame.
            if (offset.isInfinite || _animationController == null) {
              return const SizedBox.shrink();
            }

            return AnimatedBuilder(
              animation: _animationController!,
              builder: (BuildContext context, Widget? child) {
                return Visibility(
                  /// The autofocus indicator is only visible when opacity is greater than 0.
                  /// This ensures it fades out after animation to allow zooming interaction.
                  visible: (opacityTween?.value ?? 0) > 0,

                  child: Positioned(
                    // Position the autofocus animation at the last tapped focus point.
                    left: offset.dx,
                    top: offset.dy,

                    child: Opacity(
                      opacity: opacityTween?.value ?? 0, // Apply animated opacity effect.

                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent, // Ensure background is clear.
                          border: Border.all(
                            color:
                                widget.config.focusColor ??
                                Colors.white, // Use user-defined focus color.
                            width: thicknessTween?.value ?? 0, // Adjust thickness with animation.
                          ),
                        ),
                        child: child, // Placeholder for the focus frame.
                      ),
                    ),
                  ),
                );
              },
              // Defines the autofocus frame size.
              child: const SizedBox(height: _autoFocusFrameSize, width: _autoFocusFrameSize),
            );
          },
        ),
      ],
    );
  }

  /// Handles the start of a pinch-to-zoom gesture.
  /// Stores the current zoom level as the base scale for reference.
  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  /// Handles the pinch-to-zoom update.
  /// Updates the camera zoom level based on user input.
  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // Ensure a valid camera controller and that exactly two fingers are used.
    if (_controller == null || _pointers != 2) {
      return;
    }

    // Calculate the new zoom level while ensuring it stays within allowed limits.
    _currentScale = (_baseScale * details.scale).clamp(
      _minAvailableZoom ?? 2,
      _maxAvailableZoom ?? 1.0,
    );

    // Apply the new zoom level to the camera.
    await _controller!.setZoomLevel(_currentScale);
  }

  /// Handles user tap on the camera preview to set the focus and exposure point.
  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    try {
      // Normalize tap coordinates to be relative to the camera preview.
      final ui.Offset offset = Offset(
        details.localPosition.dx / constraints.maxWidth,
        details.localPosition.dy / constraints.maxHeight,
      );

      // Set the camera's focus and exposure to the tapped position.
      _controller?.setExposurePoint(offset);
      _controller?.setFocusPoint(offset);
    } catch (e) {
      logError('onViewFinderTap $e');
    }
  }

  /// Handles tap interactions to trigger the focus animation.
  void _onTapPlayFocusAnimation(TapUpDetails details) {
    try {
      // Defines the offset adjustment to center the focus animation on tap.
      const double halfAutoFocusFrameSize = _autoFocusFrameSize / 2;

      // Updates the focus frame position for the animation.
      _focusFrame?.value = details.localPosition.translate(
        -halfAutoFocusFrameSize,
        -halfAutoFocusFrameSize,
      );

      // Triggers the autofocus animation.
      _playAnimation();
    } catch (e) {
      logError('autoFocusAnimation ERROR $e');
    }
  }

  /// Plays the autofocus animation by resetting and forwarding the animation controller.
  Future<void> _playAnimation() async {
    try {
      _animationController?.reset();
      await _animationController?.forward();
    } catch (e) {
      logError('playAnimation $e');
    }
  }

  /// Converts a `Uint8List` image byte array into a `ui.Image` object.
  /// This is useful for processing images captured by the camera.
  Future<ui.Image> _convertUint8ListToImage(Uint8List list) async {
    final ui.Codec codec = await ui.instantiateImageCodec(list);
    final ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ImageProvider<Object>?> _fileToImageProvider(File file) {
    return Future<ImageProvider<Object>?>.value(FileImage(file));
  }
}
