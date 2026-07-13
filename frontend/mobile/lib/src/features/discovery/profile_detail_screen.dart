import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/data/work_needed_post_models.dart';
import 'package:connect_app/src/features/discovery/discovery_repository.dart';
import 'package:connect_app/src/features/discovery/discovery_widgets.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDetailRequest {
  const ProfileDetailRequest({
    required this.profileId,
    this.sourceType,
    this.sourceId,
  });

  final String profileId;
  final String? sourceType;
  final String? sourceId;

  @override
  bool operator ==(Object other) {
    return other is ProfileDetailRequest &&
        profileId == other.profileId &&
        sourceType == other.sourceType &&
        sourceId == other.sourceId;
  }

  @override
  int get hashCode => Object.hash(profileId, sourceType, sourceId);
}

final publicProfileDetailProvider =
    FutureProvider.family<PublicProfileDetailResult, ProfileDetailRequest>((
      ref,
      request,
    ) {
      return ref
          .watch(discoveryRepositoryProvider)
          .profile(
            request.profileId,
            sourceType: request.sourceType,
            sourceId: request.sourceId,
          );
    });

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({
    required this.profileId,
    super.key,
    this.sourceType,
    this.sourceId,
  });

  final String profileId;
  final String? sourceType;
  final String? sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ProfileDetailRequest(
      profileId: profileId,
      sourceType: sourceType,
      sourceId: sourceId,
    );
    final detail = ref.watch(publicProfileDetailProvider(request));
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: detail.when(
        loading: () => const _ProfileDetailSkeleton(),
        error: (error, _) => _DetailError(
          message: error is ApiFailure
              ? error.message
              : "Can't access internet",
          onRetry: () => ref.invalidate(publicProfileDetailProvider(request)),
        ),
        data: (value) => _ProfileDetailBody(detail: value),
      ),
    );
  }
}

class _ProfileDetailBody extends StatelessWidget {
  const _ProfileDetailBody({required this.detail});

  final PublicProfileDetailResult detail;

  @override
  Widget build(BuildContext context) {
    final role = detail.profile.role;
    if (role == 'skilled_worker') {
      return _ProfileTab(detail: detail, isKarigar: true);
    }
    final isBusiness = role == 'business';
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: VerifiedTitle(
              title: detail.profile.displayName ?? 'Profile',
              isVerified: detail.profile.isVerified,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TabBar(
            tabs: [
              Tab(text: isBusiness ? 'Work Needed' : 'Work List'),
              const Tab(text: 'Profile'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                isBusiness
                    ? _WorkNeededList(posts: detail.workNeededPosts)
                    : _WorkCardList(cards: detail.workCards),
                _ProfileTab(detail: detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkCardList extends StatelessWidget {
  const _WorkCardList({required this.cards});

  final List<WorkCardResult> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const _DetailEmpty(message: 'No published work added');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _PublicWorkCard(
          photos: card.photos,
          title: card.title,
          category: card.categoryName ?? card.customCategoryText,
          productTypes: card.productTypes,
          description: card.description,
        );
      },
    );
  }
}

class _WorkNeededList extends StatelessWidget {
  const _WorkNeededList({required this.posts});

  final List<WorkNeededPostResult> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const _DetailEmpty(message: 'No active work needed posts');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PublicWorkCard(
          photos: post.photos,
          title: post.title,
          category: post.categoryName ?? post.customCategoryText,
          productTypes: post.productTypes,
          description: post.description,
        );
      },
    );
  }
}

class _PublicWorkCard extends StatelessWidget {
  const _PublicWorkCard({
    required this.photos,
    required this.title,
    required this.productTypes,
    this.category,
    this.description,
  });

  final List<MediaAssetResult> photos;
  final String title;
  final String? category;
  final List<String> productTypes;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: connectLine),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PublicPhotoCarousel(photos: photos, height: 184),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (_hasText(category)) ...[
                    const SizedBox(height: 7),
                    Text(category!),
                  ],
                  if (productTypes.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(productTypes.join(', ')),
                  ],
                  if (_hasText(description)) ...[
                    const SizedBox(height: 10),
                    Text(description!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.detail, this.isKarigar = false});

  final PublicProfileDetailResult detail;
  final bool isKarigar;

  @override
  Widget build(BuildContext context) {
    final data = detail.roleSpecific;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        if (isKarigar)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: VerifiedTitle(
              title: detail.profile.displayName ?? 'Karigar',
              isVerified: detail.profile.isVerified,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        PublicPhotoCarousel(photos: detail.media, height: 220),
        const SizedBox(height: 20),
        if (detail.profile.role == 'business') ...[
          DetailRow(
            icon: Icons.storefront_outlined,
            label: 'Business name',
            value: _text(data['business_name']),
          ),
          DetailRow(
            icon: Icons.person_outline,
            label: 'Owner name',
            value: _text(data['owner_name']),
          ),
          DetailRow(
            icon: Icons.category_outlined,
            label: 'Business category',
            value: _text(data['business_category']),
          ),
          DetailRow(
            icon: Icons.inventory_2_outlined,
            label: 'What they manufacture / sell',
            value: _text(data['manufacture_sell_details']),
          ),
          DetailRow(
            icon: Icons.sell_outlined,
            label: 'Product types',
            value: _listText(data['product_types']),
          ),
        ] else if (detail.profile.role == 'job_worker') ...[
          DetailRow(
            icon: Icons.handyman_outlined,
            label: 'Workshop name',
            value: _text(data['workshop_name']),
          ),
          DetailRow(
            icon: Icons.person_outline,
            label: 'Owner name',
            value: _text(data['owner_name']),
          ),
          DetailRow(
            icon: Icons.category_outlined,
            label: 'Work type',
            value: _text(data['work_summary']),
          ),
          DetailRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Experience',
            value: _years(data['profile_experience_years']),
          ),
        ] else ...[
          DetailRow(
            icon: Icons.person_outline,
            label: 'Name',
            value: _text(data['owner_name']),
          ),
          DetailRow(
            icon: Icons.star_outline,
            label: 'Skill',
            value: _text(data['primary_skill']),
          ),
          DetailRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Mastery',
            value: _text(data['skill_mastery']),
          ),
          DetailRow(
            icon: Icons.history,
            label: 'Experience',
            value: _years(data['experience_years']),
          ),
        ],
        DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Locality',
          value: detail.address.locality,
        ),
        DetailRow(
          icon: Icons.home_work_outlined,
          label: 'Full address',
          value: detail.address.fullAddress,
        ),
        DetailRow(
          icon: Icons.phone_outlined,
          label: 'Contact number',
          value: detail.contact.mobile,
        ),
        const SizedBox(height: 4),
        _ContactActions(contact: detail.contact),
      ],
    );
  }

  static String? _text(Object? value) => value?.toString();

  static String? _listText(Object? value) {
    if (value is! List) {
      return null;
    }
    return value.map((item) => item.toString()).join(', ');
  }

  static String? _years(Object? value) {
    return value == null ? null : '$value years';
  }
}

class _ContactActions extends StatelessWidget {
  const _ContactActions({required this.contact});

  final PublicContactResult contact;

  @override
  Widget build(BuildContext context) {
    final mobile = contact.mobile;
    final whatsapp = contact.whatsappNumber ?? mobile;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: mobile == null
                ? null
                : () => _launch(context, Uri(scheme: 'tel', path: mobile)),
            icon: const Icon(Icons.call_outlined),
            label: const Text('Call'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: whatsapp == null
                ? null
                : () => _launch(
                    context,
                    Uri.parse(
                      'https://wa.me/${whatsapp.replaceAll(RegExp(r'\D'), '')}',
                    ),
                  ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('WhatsApp'),
          ),
        ),
      ],
    );
  }

  static Future<void> _launch(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this action')),
      );
    }
  }
}

class _DetailEmpty extends StatelessWidget {
  const _DetailEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 44, color: connectTeal),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}

class _ProfileDetailSkeleton extends StatelessWidget {
  const _ProfileDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFE8ECE8),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(
          4,
          (_) => Container(
            height: 54,
            margin: const EdgeInsets.only(bottom: 12),
            color: const Color(0xFFE8ECE8),
          ),
        ),
      ],
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44, color: connectTeal),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 14),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
