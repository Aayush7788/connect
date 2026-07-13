import 'dart:typed_data';

import 'package:flutter/material.dart';

class GalleryImage {
  const GalleryImage({this.bytes, this.url})
    : assert(bytes != null || url != null);

  final Uint8List? bytes;
  final String? url;
}

class FullScreenMediaGallery extends StatefulWidget {
  const FullScreenMediaGallery({
    required this.images,
    super.key,
    this.initialIndex = 0,
  });

  final List<GalleryImage> images;
  final int initialIndex;

  @override
  State<FullScreenMediaGallery> createState() => _FullScreenMediaGalleryState();
}

class _FullScreenMediaGalleryState extends State<FullScreenMediaGallery> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text('${_index + 1} of ${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: _image(image)),
          );
        },
      ),
    );
  }

  Widget _image(GalleryImage image) {
    if (image.bytes != null) {
      return Image.memory(image.bytes!, fit: BoxFit.contain);
    }
    return Image.network(
      image.url!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, event) {
        if (event == null) {
          return child;
        }
        return const CircularProgressIndicator(color: Colors.white);
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image_outlined,
          color: Colors.white,
          size: 48,
        );
      },
    );
  }
}
