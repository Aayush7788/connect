import 'dart:async';

import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/media/full_screen_media_gallery.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';

class PublicPhotoCarousel extends StatefulWidget {
  const PublicPhotoCarousel({
    required this.photos,
    super.key,
    this.height = 190,
    this.autoAdvance = false,
  });

  final List<MediaAssetResult> photos;
  final double height;
  final bool autoAdvance;

  @override
  State<PublicPhotoCarousel> createState() => _PublicPhotoCarouselState();
}

class _PublicPhotoCarouselState extends State<PublicPhotoCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  List<MediaAssetResult> get _visiblePhotos => widget.photos
      .where((photo) => photo.url != null || photo.thumbnailUrl != null)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant PublicPhotoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photos.length != widget.photos.length ||
        oldWidget.autoAdvance != widget.autoAdvance) {
      _index = 0;
      _timer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    if (!widget.autoAdvance || _visiblePhotos.length < 2) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final next = (_index + 1) % _visiblePhotos.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = _visiblePhotos;
    if (photos.isEmpty) {
      return Container(
        height: widget.height,
        color: const Color(0xFFE8ECE8),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 38),
            SizedBox(height: 8),
            Text('No photos'),
          ],
        ),
      );
    }
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: photos.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final photo = photos[index];
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FullScreenMediaGallery(
                      images: photos
                          .map(
                            (item) => GalleryImage(
                              url: item.url ?? item.thumbnailUrl!,
                            ),
                          )
                          .toList(growable: false),
                      initialIndex: index,
                    ),
                  ),
                ),
                child: Image.network(
                  photo.thumbnailUrl ?? photo.url!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE8ECE8),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 38),
                  ),
                ),
              );
            },
          ),
          if (photos.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  photos.length,
                  (index) => Container(
                    width: index == _index ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index == _index ? connectTeal : Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VerifiedTitle extends StatelessWidget {
  const VerifiedTitle({
    required this.title,
    required this.isVerified,
    super.key,
    this.style,
  });

  final String title;
  final bool isVerified;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: style ?? Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 5),
          const Tooltip(
            message: 'Verified profile',
            child: Icon(Icons.verified, size: 20, color: Color(0xFF1473E6)),
          ),
        ],
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: connectTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(value!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
