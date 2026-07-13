import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:connect_app/src/features/profile/profile_display.dart';
import 'package:connect_app/src/features/work_cards/work_card_owner_list.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_owner_list.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyProfileDashboard extends ConsumerStatefulWidget {
  const MyProfileDashboard({
    super.key,
    this.onWorkListSelectionChanged,
    this.onWorkNeededSelectionChanged,
  });

  final ValueChanged<bool>? onWorkListSelectionChanged;
  final ValueChanged<bool>? onWorkNeededSelectionChanged;

  @override
  ConsumerState<MyProfileDashboard> createState() => _MyProfileDashboardState();
}

class _MyProfileDashboardState extends ConsumerState<MyProfileDashboard> {
  bool _showOwnerList = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    if (profileState.isLoading && profileState.profile == null) {
      return const _ProfileLoading();
    }
    if (profileState.errorMessage != null && profileState.profile == null) {
      return _ProfileError(
        message: profileState.errorMessage!,
        onRetry: () =>
            ref.read(profileControllerProvider.notifier).load(force: true),
      );
    }
    final ownerProfile = profileState.profile;
    if (ownerProfile == null) {
      return const SizedBox.shrink();
    }
    final profile = ownerProfile.profile;
    final missing = profile.completionFlags.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList(growable: false);
    final isPending = profile.verificationStatus == 'pending';
    final isHidden = profile.visibilityStatus == 'hidden_by_user';
    final isJobWorker = profile.role == 'job_worker';
    final isBusiness = profile.role == 'business';
    final header = Row(
      children: [
        Expanded(
          child: Text(
            'My Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );

    if ((isJobWorker || isBusiness) && _showOwnerList) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 14),
          if (isJobWorker)
            _JobWorkerProfileTabs(
              showWorkList: true,
              onChanged: (selected) =>
                  _setOwnerListSelected(selected, profile.role),
            )
          else
            _BusinessProfileTabs(
              showPosts: true,
              onChanged: (selected) =>
                  _setOwnerListSelected(selected, profile.role),
            ),
          const SizedBox(height: 18),
          if (isJobWorker)
            const WorkCardOwnerList()
          else
            const WorkNeededPostOwnerList(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        if (isJobWorker) ...[
          const SizedBox(height: 14),
          _JobWorkerProfileTabs(
            showWorkList: false,
            onChanged: (selected) =>
                _setOwnerListSelected(selected, profile.role),
          ),
        ],
        if (isBusiness) ...[
          const SizedBox(height: 14),
          _BusinessProfileTabs(
            showPosts: false,
            onChanged: (selected) =>
                _setOwnerListSelected(selected, profile.role),
          ),
        ],
        if (isHidden) ...[
          const SizedBox(height: 8),
          const _StatusBanner(
            icon: Icons.visibility_off_outlined,
            text: 'Hidden from search',
            color: connectAmber,
          ),
        ],
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName?.trim().isNotEmpty == true
                              ? profile.displayName!
                              : authState.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(profileRoleLabel(profile.role)),
                        const SizedBox(height: 4),
                        Text(authState.me?.user.primaryMobile ?? ''),
                      ],
                    ),
                  ),
                  Text(
                    '${profile.completionScore}%',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: connectTeal),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: profile.completionScore / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text('${profile.completionScore}% complete'),
              if (profile.verificationStatus != 'unverified') ...[
                const SizedBox(height: 12),
                _VerificationBadge(status: profile.verificationStatus),
              ],
              const SizedBox(height: 16),
              PrimaryActionButton(
                label: profile.completionScore == 100
                    ? 'Edit Profile'
                    : 'Complete your profile to get business',
                onPressed: isPending
                    ? null
                    : () => context.push('/profile/complete'),
              ),
            ],
          ),
        ),
        if (isPending) ...[
          const SizedBox(height: 12),
          const _StatusBanner(
            icon: Icons.lock_outline,
            text: 'Profile editing is locked while verification is pending',
            color: connectTeal,
          ),
        ],
        if (missing.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Complete next', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...missing
              .take(4)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.circle_outlined,
                        size: 18,
                        color: connectAmber,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(completionItemLabel(item))),
                    ],
                  ),
                ),
              ),
        ],
        const SizedBox(height: 20),
        _OwnerPreview(ownerProfile: ownerProfile),
        const SizedBox(height: 16),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: connectAmber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  missing.isEmpty
                      ? 'Keep your profile details up to date'
                      : completionItemLabel(missing.first),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setOwnerListSelected(bool selected, String role) {
    setState(() => _showOwnerList = selected);
    if (role == 'job_worker') {
      widget.onWorkListSelectionChanged?.call(selected);
    } else if (role == 'business') {
      widget.onWorkNeededSelectionChanged?.call(selected);
    }
  }
}

class _JobWorkerProfileTabs extends StatelessWidget {
  const _JobWorkerProfileTabs({
    required this.showWorkList,
    required this.onChanged,
  });

  final bool showWorkList;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            icon: Icon(Icons.view_list_outlined),
            label: Text('Work List'),
          ),
          ButtonSegment(
            value: false,
            icon: Icon(Icons.person_outline),
            label: Text('My Profile', key: Key('job-worker-profile-tab')),
          ),
        ],
        selected: {showWorkList},
        onSelectionChanged: (values) => onChanged(values.first),
        showSelectedIcon: false,
      ),
    );
  }
}

class _BusinessProfileTabs extends StatelessWidget {
  const _BusinessProfileTabs({
    required this.showPosts,
    required this.onChanged,
  });

  final bool showPosts;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            icon: Icon(Icons.post_add_outlined),
            label: Text('Work Needed Posts'),
          ),
          ButtonSegment(
            value: false,
            icon: Icon(Icons.person_outline),
            label: Text('My Profile', key: Key('business-profile-tab')),
          ),
        ],
        selected: {showPosts},
        onSelectionChanged: (values) => onChanged(values.first),
        showSelectedIcon: false,
      ),
    );
  }
}

class _OwnerPreview extends StatelessWidget {
  const _OwnerPreview({required this.ownerProfile});

  final OwnerProfileResult ownerProfile;

  @override
  Widget build(BuildContext context) {
    final profile = ownerProfile.profile;
    final details = ownerProfile.roleSpecific;
    final rows = <MapEntry<String, String>>[];
    if (profile.role == 'business') {
      rows.addAll([
        MapEntry('Business', details['business_name']?.toString() ?? ''),
        MapEntry(
          'Manufacture / sell',
          details['manufacture_sell_details']?.toString() ?? '',
        ),
      ]);
    } else if (profile.role == 'job_worker') {
      rows.addAll([
        MapEntry('Workshop', details['workshop_name']?.toString() ?? ''),
        MapEntry('Work', details['work_summary']?.toString() ?? ''),
      ]);
    } else {
      rows.addAll([
        MapEntry('Skill', details['skill_mastery']?.toString() ?? ''),
        MapEntry(
          'Experience',
          details['experience_years'] == null
              ? ''
              : '${details['experience_years']} years',
        ),
      ]);
    }
    rows.add(MapEntry('Locality', details['locality']?.toString() ?? ''));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile preview', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profile.displayName ?? 'Your profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (profile.isVerified)
                    const Icon(Icons.verified, color: Color(0xFF2563EB)),
                ],
              ),
              const SizedBox(height: 14),
              ...rows
                  .where((row) => row.value.trim().isNotEmpty)
                  .map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.key,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(row.value),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified_user_outlined, size: 18, color: connectTeal),
        const SizedBox(width: 6),
        Text(profileStatusLabel(status)),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        const SizedBox(height: 180, child: AppCard(child: _SkeletonLines())),
      ],
    );
  }
}

class _SkeletonLines extends StatelessWidget {
  const _SkeletonLines();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          height: index == 0 ? 24 : 14,
          margin: const EdgeInsets.only(bottom: 14),
          color: connectLine,
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off_outlined, size: 44, color: connectAmber),
        const SizedBox(height: 12),
        Text(message, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
