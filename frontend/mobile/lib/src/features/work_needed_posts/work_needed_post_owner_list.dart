import 'package:connect_app/src/data/work_needed_post_models.dart';
import 'package:connect_app/src/features/work_needed_posts/work_needed_post_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkNeededPostOwnerList extends ConsumerStatefulWidget {
  const WorkNeededPostOwnerList({super.key});

  @override
  ConsumerState<WorkNeededPostOwnerList> createState() =>
      _WorkNeededPostOwnerListState();
}

class _WorkNeededPostOwnerListState
    extends ConsumerState<WorkNeededPostOwnerList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workNeededPostControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workNeededPostControllerProvider);
    if (state.isLoading && state.posts.isEmpty) {
      return const _PostListLoading();
    }
    if (state.errorMessage != null && state.posts.isEmpty) {
      return _PostListError(
        message: state.errorMessage!,
        onRetry: () => ref
            .read(workNeededPostControllerProvider.notifier)
            .load(force: true),
      );
    }
    if (state.posts.isEmpty) {
      return const _EmptyPostList();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.errorMessage != null) ...[
          _InlineError(message: state.errorMessage!),
          const SizedBox(height: 12),
        ],
        ...state.posts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _OwnerPostCard(
              post: post,
              disabled: state.isSaving,
              onAction: (action) => _handleAction(action, post),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    _PostAction action,
    WorkNeededPostResult post,
  ) async {
    final controller = ref.read(workNeededPostControllerProvider.notifier);
    switch (action) {
      case _PostAction.edit:
        await context.push<bool>('/work-needed-posts/${post.id}/edit');
      case _PostAction.pause:
        final success = await controller.pause(post);
        if (mounted) {
          _showResult(success, 'Post paused');
        }
      case _PostAction.resume:
        final success = await controller.resume(post);
        if (mounted) {
          _showResult(success, 'Post active');
        }
      case _PostAction.close:
        final confirmed = await _confirm(
          title: 'Close this post?',
          message: 'Job workers will no longer see it as active.',
          actionLabel: 'Close',
        );
        if (confirmed) {
          final success = await controller.close(post);
          if (mounted) {
            _showResult(success, 'Post closed');
          }
        }
      case _PostAction.delete:
        final confirmed = await _confirm(
          title: 'Delete this post?',
          message: 'This post will be removed from your list.',
          actionLabel: 'Delete',
        );
        if (confirmed) {
          final success = await controller.delete(post);
          if (mounted) {
            _showResult(success, 'Post deleted');
          }
        }
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(actionLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showResult(bool success, String successMessage) {
    final state = ref.read(workNeededPostControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : state.errorMessage ?? 'Unable to update post',
        ),
      ),
    );
  }
}

enum _PostAction { edit, pause, resume, close, delete }

class _OwnerPostCard extends StatelessWidget {
  const _OwnerPostCard({
    required this.post,
    required this.disabled,
    required this.onAction,
  });

  final WorkNeededPostResult post;
  final bool disabled;
  final ValueChanged<_PostAction> onAction;

  @override
  Widget build(BuildContext context) {
    final cover = post.photos.isEmpty
        ? null
        : post.photos.first.thumbnailUrl ?? post.photos.first.url;
    return AppCard(
      onTap: disabled ? null : () => onAction(_PostAction.edit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: cover == null
                  ? const _PostPhotoPlaceholder()
                  : Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _PostPhotoPlaceholder(),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  post.displayWorkName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              PopupMenuButton<_PostAction>(
                enabled: !disabled,
                tooltip: 'Post actions',
                onSelected: onAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _PostAction.edit,
                    child: _MenuLabel(Icons.edit_outlined, 'Edit post'),
                  ),
                  if (post.status == 'active')
                    const PopupMenuItem(
                      value: _PostAction.pause,
                      child: _MenuLabel(Icons.pause_outlined, 'Pause'),
                    ),
                  if (post.status == 'paused')
                    const PopupMenuItem(
                      value: _PostAction.resume,
                      child: _MenuLabel(Icons.play_arrow_outlined, 'Resume'),
                    ),
                  if (post.status == 'active' || post.status == 'paused')
                    const PopupMenuItem(
                      value: _PostAction.close,
                      child: _MenuLabel(Icons.check_circle_outline, 'Close'),
                    ),
                  const PopupMenuItem(
                    value: _PostAction.delete,
                    child: _MenuLabel(Icons.delete_outline, 'Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(post.displayCategory),
          if (post.productTypes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(post.productTypes.join(', ')),
          ],
          const SizedBox(height: 12),
          _StatusChip(status: post.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('Active', connectTeal),
      'paused' => ('Paused', connectAmber),
      'closed_by_user' => ('Closed', const Color(0xFF6B7280)),
      'removed_by_admin' => ('Removed', const Color(0xFFB91C1C)),
      _ => ('Draft', const Color(0xFF6B7280)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon, size: 20), const SizedBox(width: 10), Text(label)],
    );
  }
}

class _EmptyPostList extends StatelessWidget {
  const _EmptyPostList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.post_add_outlined, size: 52, color: connectTeal),
            const SizedBox(height: 14),
            Text(
              'Find work by posting',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostListLoading extends StatelessWidget {
  const _PostListLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          height: 260,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _PostListError extends StatelessWidget {
  const _PostListError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF991B1B))),
    );
  }
}

class _PostPhotoPlaceholder extends StatelessWidget {
  const _PostPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 44,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}
