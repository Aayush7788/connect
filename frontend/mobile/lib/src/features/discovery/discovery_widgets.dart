import 'dart:async';

import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
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

class KarigarPortrait extends StatelessWidget {
  const KarigarPortrait({required this.photos, required this.size, super.key});

  final List<MediaAssetResult> photos;
  final double size;

  @override
  Widget build(BuildContext context) {
    MediaAssetResult? photo;
    for (final item in photos) {
      if (item.thumbnailUrl != null || item.url != null) {
        photo = item;
        break;
      }
    }
    final selectedPhoto = photo;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8ECE8),
        border: Border.all(color: connectLine),
      ),
      child: selectedPhoto == null
          ? Icon(Icons.person_outline, size: size * 0.46, color: connectTeal)
          : InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FullScreenMediaGallery(
                    images: [
                      GalleryImage(
                        url: selectedPhoto.url ?? selectedPhoto.thumbnailUrl!,
                      ),
                    ],
                  ),
                ),
              ),
              child: Image.network(
                selectedPhoto.thumbnailUrl ?? selectedPhoto.url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.person_outline,
                  size: size * 0.46,
                  color: connectTeal,
                ),
              ),
            ),
    );
  }
}

class KarigarResultCard extends StatelessWidget {
  const KarigarResultCard({
    required this.result,
    required this.onTap,
    super.key,
    this.trailing,
  });

  final MarketplaceSearchResult result;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final skills = result.skills.isNotEmpty
        ? result.skills.join(', ')
        : result.category;
    return Material(
      key: const Key('karigar-result-card'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 172),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: connectLine),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerifiedTitle(
                      title: result.title,
                      isVerified: result.isVerified,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _KarigarFact(label: 'Skills', value: skills),
                    _KarigarFact(label: 'Mastery', value: result.subtitle),
                    _KarigarFact(label: 'Locality', value: result.locality),
                    _KarigarFact(
                      label: 'Experience',
                      value: result.experienceYears == null
                          ? null
                          : '${result.experienceYears} years',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KarigarPortrait(
                    key: const Key('karigar-profile-photo'),
                    photos: result.photos,
                    size: 112,
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 4),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KarigarFact extends StatelessWidget {
  const _KarigarFact({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text.rich(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
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
