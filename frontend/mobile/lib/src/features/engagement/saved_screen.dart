import 'package:connect_app/src/data/engagement_models.dart';
import 'package:connect_app/src/features/discovery/discovery_widgets.dart';
import 'package:connect_app/src/features/discovery/search_screen.dart';
import 'package:connect_app/src/features/engagement/engagement_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementControllerProvider.notifier).loadSaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementControllerProvider);
    final listHeight = (MediaQuery.sizeOf(context).height - 230).clamp(
      360.0,
      900.0,
    );
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          const TabBar(
            tabs: [
              Tab(text: 'Business'),
              Tab(text: 'Job Worker'),
              Tab(text: 'Karigar'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: listHeight,
            child: state.isLoadingSaved && state.savedItems.isEmpty
                ? const _SavedLoading()
                : TabBarView(
                    children: [
                      _SavedList(items: _forRole(state.savedItems, 'business')),
                      _SavedList(
                        items: _forRole(state.savedItems, 'job_worker'),
                      ),
                      _SavedList(
                        items: _forRole(state.savedItems, 'skilled_worker'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static List<SavedItemResult> _forRole(
    List<SavedItemResult> items,
    String role,
  ) {
    return items
        .where((item) => item.profileRole == role)
        .toList(growable: false);
  }
}

class _SavedList extends ConsumerWidget {
  const _SavedList({required this.items});

  final List<SavedItemResult> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_outlined, size: 44, color: connectTeal),
            SizedBox(height: 12),
            Text('No saved profiles'),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(engagementControllerProvider.notifier).loadSaved(),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final card = item.card;
          if (card == null) {
            return const AppCard(child: Text('This saved item is unavailable'));
          }
          if (item.profileRole == 'skilled_worker') {
            return KarigarResultCard(
              result: card,
              onTap: () => context.push(
                '/profiles/${card.profileId}',
                extra: ProfileDetailRouteExtra(
                  sourceType: 'profile',
                  sourceId: item.id,
                ),
              ),
              trailing: IconButton(
                tooltip: 'Remove',
                onPressed: () => ref
                    .read(engagementControllerProvider.notifier)
                    .removeSaved(item.id),
                icon: const Icon(Icons.bookmark_remove_outlined),
              ),
            );
          }
          return AppCard(
            onTap: () => context.push(
              '/profiles/${card.profileId}',
              extra: ProfileDetailRouteExtra(
                sourceType: 'profile',
                sourceId: item.id,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PublicPhotoCarousel(photos: card.photos, height: 150),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: VerifiedTitle(
                        title: card.title,
                        isVerified: card.isVerified,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => ref
                          .read(engagementControllerProvider.notifier)
                          .removeSaved(item.id),
                      icon: const Icon(Icons.bookmark_remove_outlined),
                    ),
                  ],
                ),
                if (card.category != null) ...[
                  const SizedBox(height: 6),
                  Text(card.category!),
                ],
                if (card.locality != null) ...[
                  const SizedBox(height: 6),
                  Text(card.locality!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SavedLoading extends StatelessWidget {
  const _SavedLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFE8ECE8),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
