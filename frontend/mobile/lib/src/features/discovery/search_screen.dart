import 'dart:async';

import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/discovery_models.dart';
import 'package:connect_app/src/features/discovery/discovery_controller.dart';
import 'package:connect_app/src/features/discovery/discovery_widgets.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.initialTarget = 'job_worker',
    this.initialQuery = '',
  });

  final String initialTarget;
  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialQuery,
  );
  late final String _initialTarget = _targets.contains(widget.initialTarget)
      ? widget.initialTarget
      : 'job_worker';
  Timer? _debounce;

  static const _targets = ['business', 'job_worker', 'skilled_worker'];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(discoveryControllerProvider.notifier)
          .configure(target: _initialTarget, initialQuery: widget.initialQuery),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_title(state.target))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('marketplace-search-field'),
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: state.target == 'job_worker'
                            ? 'Search work like flat hemming, embroidery'
                            : 'Search for profile/work',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                  ref
                                      .read(
                                        discoveryControllerProvider.notifier,
                                      )
                                      .updateQuery('');
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 550),
                          () {
                            ref
                                .read(discoveryControllerProvider.notifier)
                                .updateQuery(value);
                          },
                        );
                      },
                      onSubmitted: (value) {
                        _debounce?.cancel();
                        ref
                            .read(discoveryControllerProvider.notifier)
                            .updateQuery(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Filters',
                    onPressed: () => _showFilters(state),
                    icon: Badge(
                      isLabelVisible: state.hasFilters,
                      child: const Icon(Icons.tune),
                    ),
                  ),
                ],
              ),
            ),
            if (state.target == 'business')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'work_needed_posts',
                      label: Text('Work needed'),
                    ),
                    ButtonSegment(value: 'profiles', label: Text('Profiles')),
                  ],
                  selected: {state.businessMode},
                  onSelectionChanged: (selection) => ref
                      .read(discoveryControllerProvider.notifier)
                      .setBusinessMode(selection.first),
                ),
              ),
            if (state.target == 'job_worker')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'work_cards', label: Text('Work')),
                    ButtonSegment(value: 'profiles', label: Text('Profiles')),
                  ],
                  selected: {state.jobWorkerMode},
                  onSelectionChanged: (selection) => ref
                      .read(discoveryControllerProvider.notifier)
                      .setJobWorkerMode(selection.first),
                ),
              ),
            if (state.query.trim().isNotEmpty && !state.isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Showing best matches for ${state.query.trim()}'),
                ),
              ),
            Expanded(child: _body(state)),
          ],
        ),
      ),
    );
  }

  Widget _body(DiscoveryState state) {
    if (state.isLoading && !state.isInitialized) {
      return const _SearchSkeleton();
    }
    if (state.errorMessage != null && state.results.isEmpty) {
      return _SearchMessage(
        icon: Icons.cloud_off_outlined,
        message: state.errorMessage!,
        actionLabel: 'Retry',
        onAction: ref.read(discoveryControllerProvider.notifier).search,
      );
    }
    if (state.isLoading && state.results.isEmpty) {
      return const _SearchSkeleton();
    }
    if (state.results.isEmpty) {
      return _SearchMessage(
        icon: Icons.person_add_alt_1_outlined,
        message: state.query.trim().isEmpty
            ? 'Search for profile/work'
            : 'Invite someone you know',
        actionLabel: state.hasFilters ? 'Clear filters' : 'Share app',
        onAction: state.hasFilters
            ? ref.read(discoveryControllerProvider.notifier).clearFilters
            : () => SharePlus.instance.share(
                ShareParams(text: 'Join me on Connect for textile work.'),
              ),
      );
    }
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: ref.read(discoveryControllerProvider.notifier).search,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: state.results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final result = state.results[index];
              return _SearchResultCard(
                result: result,
                isKarigar: state.target == 'skilled_worker',
                onTap: () => context.push(
                  '/profiles/${result.profileId}',
                  extra: ProfileDetailRouteExtra(
                    sourceType: result.resultType,
                    sourceId: result.id,
                    preview: result,
                  ),
                ),
              );
            },
          ),
        ),
        if (state.isLoading)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Future<void> _showFilters(DiscoveryState state) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _FilterSheet(initial: state),
    );
  }

  static String _title(String target) => switch (target) {
    'business' => 'Find Business',
    'skilled_worker' => 'Find Karigar',
    _ => 'Find Job Worker',
  };
}

class ProfileDetailRouteExtra {
  const ProfileDetailRouteExtra({this.sourceType, this.sourceId, this.preview});

  final String? sourceType;
  final String? sourceId;
  final MarketplaceSearchResult? preview;
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.result,
    required this.onTap,
    required this.isKarigar,
  });

  final MarketplaceSearchResult result;
  final VoidCallback onTap;
  final bool isKarigar;

  @override
  Widget build(BuildContext context) {
    if (isKarigar) {
      return KarigarResultCard(result: result, onTap: onTap);
    }
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: connectLine),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PublicPhotoCarousel(
                photos: result.photos,
                height: 184,
                autoAdvance: true,
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerifiedTitle(
                      title: result.title,
                      isVerified: result.isVerified,
                    ),
                    if (_hasText(result.category)) ...[
                      const SizedBox(height: 7),
                      Text(result.category!),
                    ],
                    if (result.productTypes.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(result.productTypes.join(', ')),
                    ],
                    if (_hasText(result.subtitle)) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(result.subtitle!)),
                        ],
                      ),
                    ],
                    if (_hasText(result.locality)) ...[
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(result.locality!)),
                        ],
                      ),
                    ],
                    if (result.experienceYears != null) ...[
                      const SizedBox(height: 7),
                      Text('${result.experienceYears} years experience'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial});

  final DiscoveryState initial;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late String? _categoryId = widget.initial.categoryId;
  late String? _productTypeId = widget.initial.productTypeId;
  late final TextEditingController _locality = TextEditingController(
    text: widget.initial.locality,
  );
  late final TextEditingController _minimum = TextEditingController(
    text: widget.initial.minExperienceYears?.toString() ?? '',
  );
  late final TextEditingController _maximum = TextEditingController(
    text: widget.initial.maxExperienceYears?.toString() ?? '',
  );
  late bool _verifiedOnly = widget.initial.verifiedOnly;
  late String _sort = widget.initial.sort;

  @override
  void dispose() {
    _locality.dispose();
    _minimum.dispose();
    _maximum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxonomy = widget.initial.taxonomy;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category / work type',
              ),
              items: _items(taxonomy['category'] ?? const []),
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _productTypeId,
              decoration: const InputDecoration(labelText: 'Product type'),
              items: _items(taxonomy['product_type'] ?? const []),
              onChanged: (value) => setState(() => _productTypeId = value),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _locality,
              decoration: const InputDecoration(
                labelText: 'Locality',
                hintText: 'Example: Ring Road',
              ),
            ),
            if (widget.initial.target != 'business') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minimum,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min experience',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maximum,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max experience',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Verified only'),
              value: _verifiedOnly,
              onChanged: (value) => setState(() => _verifiedOnly = value),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _sort,
              decoration: const InputDecoration(labelText: 'Sort results'),
              items: const [
                DropdownMenuItem(value: 'best', child: Text('Best match')),
                DropdownMenuItem(
                  value: 'verified_first',
                  child: Text('Verified first'),
                ),
                DropdownMenuItem(value: 'nearby', child: Text('Nearby')),
                DropdownMenuItem(
                  value: 'most_photos',
                  child: Text('Most photos'),
                ),
                DropdownMenuItem(
                  value: 'recent',
                  child: Text('Recently added'),
                ),
              ],
              onChanged: (value) => setState(() => _sort = value ?? 'best'),
            ),
            const SizedBox(height: 20),
            PrimaryActionButton(
              label: 'Apply',
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(discoveryControllerProvider.notifier)
                    .applyFilters(
                      categoryId: _categoryId,
                      productTypeId: _productTypeId,
                      locality: _locality.text,
                      minExperienceYears: int.tryParse(_minimum.text),
                      maxExperienceYears: int.tryParse(_maximum.text),
                      verifiedOnly: _verifiedOnly,
                      sort: _sort,
                    );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(discoveryControllerProvider.notifier)
                    .clearFilters();
              },
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }

  static List<DropdownMenuItem<String>> _items(List<CategoryOption> options) {
    return options
        .map(
          (option) => DropdownMenuItem(
            value: option.id,
            child: Text(option.name, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(growable: false);
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, _) => Container(
        height: 270,
        decoration: BoxDecoration(
          color: const Color(0xFFE8ECE8),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final FutureOr<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: connectTeal),
            const SizedBox(height: 14),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 18),
            SizedBox(
              width: 190,
              child: FilledButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
