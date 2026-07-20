import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/data/work_needed_post_models.dart';
import 'package:connect_app/src/features/discovery/discovery_repository.dart';
import 'package:connect_app/src/features/discovery/discovery_widgets.dart';
import 'package:connect_app/src/features/engagement/engagement_controller.dart';
import 'package:connect_app/src/features/engagement/profile_actions.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({
    required this.profileId,
    super.key,
    this.sourceType,
    this.sourceId,
    this.preview,
  });

  final String profileId;
  final String? sourceType;
  final String? sourceId;
  final MarketplaceSearchResult? preview;

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementControllerProvider.notifier).loadSaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = ProfileDetailRequest(
      profileId: widget.profileId,
      sourceType: widget.sourceType,
      sourceId: widget.sourceId,
    );
    final detail = ref.watch(publicProfileDetailProvider(request));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: () => shareProfile(context, ref, widget.profileId),
            icon: const Icon(Icons.share_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            onSelected: (value) {
              if (value == 'report') {
                reportProfile(context, ref, widget.profileId);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: detail.when(
        loading: () => widget.preview == null
            ? const _ProfileDetailSkeleton()
            : _ProfileDetailPreview(preview: widget.preview!),
        error: (error, _) => _DetailError(
          message: error is ApiFailure
              ? error.message
              : "Can't access internet",
          onRetry: () => ref.invalidate(publicProfileDetailProvider(request)),
        ),
        data: (value) => _ProfileDetailBody(
          detail: value,
          sourceType: widget.sourceType,
          sourceId: widget.sourceId,
        ),
      ),
    );
  }
}

class _ProfileDetailBody extends ConsumerWidget {
  const _ProfileDetailBody({
    required this.detail,
    this.sourceType,
    this.sourceId,
  });

  final PublicProfileDetailResult detail;
  final String? sourceType;
  final String? sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = detail.profile.role;
    if (role == 'skilled_worker') {
      return _ProfileTab(
        detail: detail,
        isKarigar: true,
        sourceType: sourceType,
        sourceId: sourceId,
      );
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
                _ProfileTab(
                  detail: detail,
                  sourceType: sourceType,
                  sourceId: sourceId,
                ),
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

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab({
    required this.detail,
    this.isKarigar = false,
    this.sourceType,
    this.sourceId,
  });

  final PublicProfileDetailResult detail;
  final bool isKarigar;
  final String? sourceType;
  final String? sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        if (isKarigar)
          Center(child: KarigarPortrait(photos: detail.media, size: 180))
        else
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
            label: 'Skills',
            value: _listText(data['skills']) ?? _text(data['primary_skill']),
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
        _ContactActions(
          profileId: detail.profile.id,
          contact: detail.contact,
          sourceType: sourceType,
          sourceId: sourceId,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: ref.watch(engagementControllerProvider).isSaving
              ? null
              : () async {
                  final changed = await ref
                      .read(engagementControllerProvider.notifier)
                      .toggleProfile(detail.profile.id);
                  if (!changed && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ref.read(engagementControllerProvider).errorMessage ??
                              'Unable to update saved profiles',
                        ),
                      ),
                    );
                  }
                },
          icon: Icon(
            ref
                        .watch(engagementControllerProvider.notifier)
                        .savedProfile(detail.profile.id) ==
                    null
                ? Icons.bookmark_border_outlined
                : Icons.bookmark,
          ),
          label: Text(
            ref
                        .watch(engagementControllerProvider.notifier)
                        .savedProfile(detail.profile.id) ==
                    null
                ? 'Save'
                : 'Saved',
          ),
        ),
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

class _ContactActions extends ConsumerWidget {
  const _ContactActions({
    required this.profileId,
    required this.contact,
    this.sourceType,
    this.sourceId,
  });

  final String profileId;
  final PublicContactResult contact;
  final String? sourceType;
  final String? sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobile = contact.mobile;
    final whatsapp = contact.whatsappNumber ?? mobile;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: mobile == null
                ? null
                : () => logThenLaunchContact(
                    context: context,
                    ref: ref,
                    profileId: profileId,
                    actionType: 'call',
                    sourceType: sourceType,
                    sourceId: sourceId,
                    uri: Uri(scheme: 'tel', path: mobile),
                  ),
            icon: const Icon(Icons.call_outlined),
            label: const Text('Call'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: whatsapp == null
                ? null
                : () => logThenLaunchContact(
                    context: context,
                    ref: ref,
                    profileId: profileId,
                    actionType: 'whatsapp',
                    sourceType: sourceType,
                    sourceId: sourceId,
                    uri: Uri.parse(
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

class _ProfileDetailPreview extends StatelessWidget {
  const _ProfileDetailPreview({required this.preview});

  final MarketplaceSearchResult preview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 14),
        if (preview.skills.isNotEmpty)
          Center(child: KarigarPortrait(photos: preview.photos, size: 180))
        else
          PublicPhotoCarousel(photos: preview.photos, height: 220),
        const SizedBox(height: 16),
        VerifiedTitle(
          title: preview.title,
          isVerified: preview.isVerified,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (preview.subtitle != null &&
            preview.subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(preview.subtitle!),
        ],
        if (preview.category != null &&
            preview.category!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(preview.category!),
        ],
        if (preview.productTypes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(preview.productTypes.join(', ')),
        ],
        if (preview.locality != null &&
            preview.locality!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(preview.locality!)),
            ],
          ),
        ],
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
