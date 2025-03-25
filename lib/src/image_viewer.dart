import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key, required this.image});

  final Future<ImageProvider<Object>?> image;

  @override
  State createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  bool isImageLandscape = false;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _determineImageOrientation();
  }

  void _determineImageOrientation() async {
    final ImageProvider<Object>? imageProvider = await widget.image;
    if (imageProvider == null) return;

    final ImageStream stream = imageProvider.resolve(ImageConfiguration());
    _imageStream = stream;
    _imageStreamListener = ImageStreamListener((ImageInfo info, bool _) {
      final int width = info.image.width;
      final int height = info.image.height;
      if (mounted) {
        setState(() {
          isImageLandscape = width > height;
        });
      }
    });
    stream.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageStreamListener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            body: OrientationBuilder(
              builder: (BuildContext ctx, Orientation orientation) {
                final bool isPortrait = orientation == Orientation.portrait;
                return SafeArea(
                  top: isPortrait ? false : true,
                  left: false,
                  right: false,
                  bottom: false,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: PhotoViewGallery(
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          loadingBuilder:
                              (context, event) => const Center(
                                child: CircularProgressIndicator(),
                              ),
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
                      Positioned(
                        top: isPortrait ? 40 : 0,
                        left: isPortrait ? 0 : 20,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          iconSize: 35,
                          icon: CircleAvatar(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            child: const Icon(
                              Icons.clear,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: isPortrait ? 45 : 0,
                        right: 20,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context, true),
                          padding: const EdgeInsets.all(0),
                          icon: CircleAvatar(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
