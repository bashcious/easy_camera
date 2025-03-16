import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider<Object>?>(
      future: image,
      builder: (BuildContext context, AsyncSnapshot<ImageProvider<Object>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Icon(Icons.error));
        } else {
          return SafeArea(
            bottom: false,
            child: Scaffold(
              body: Container(
                color: Colors.black,
                height: MediaQuery.sizeOf(context).height,
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8, left: 16, bottom: 5),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PhotoViewGallery(
                        backgroundDecoration: const BoxDecoration(color: Colors.black),
                        loadingBuilder:
                            (BuildContext context, ImageChunkEvent? event) =>
                                const Center(child: CircularProgressIndicator()),
                        pageOptions: <PhotoViewGalleryPageOptions>[
                          PhotoViewGalleryPageOptions(
                            imageProvider: snapshot.data,
                            heroAttributes: const PhotoViewHeroAttributes(tag: 'imageHero'),
                            minScale: PhotoViewComputedScale.contained,
                            tightMode: true,
                            initialScale: PhotoViewComputedScale.contained,
                            basePosition: Alignment.topCenter,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: <Widget>[
                          Flexible(
                            child: OutlinedButton(
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
                            ),
                          ),
                          Flexible(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(2),
                              ).copyWith(
                                side: WidgetStateProperty.resolveWith<BorderSide>((_) {
                                  return const BorderSide(color: Color(0xffBBFBD0));
                                }),
                              ),
                              child: const Icon(Icons.check, color: Color(0xffBBFBD0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
