import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/features/work_cards/work_card_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkCardOwnerList extends ConsumerStatefulWidget {
  const WorkCardOwnerList({super.key});

  @override
  ConsumerState<WorkCardOwnerList> createState() => _WorkCardOwnerListState();
}

class _WorkCardOwnerListState extends ConsumerState<WorkCardOwnerList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workCardControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workCardControllerProvider);
    if (state.isLoading && state.cards.isEmpty) {
      return const _WorkListLoading();
    }
    if (state.errorMessage != null && state.cards.isEmpty) {
      return _WorkListError(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(workCardControllerProvider.notifier).load(force: true),
      );
    }
    if (state.cards.isEmpty) {
      return const _EmptyWorkList();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.errorMessage != null) ...[
          _InlineError(message: state.errorMessage!),
          const SizedBox(height: 12),
        ],
        ...state.cards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _OwnerWorkCard(
              card: card,
              disabled: state.isSaving,
              onAction: (action) => _handleAction(action, card),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    _WorkCardAction action,
    WorkCardResult card,
  ) async {
    final controller = ref.read(workCardControllerProvider.notifier);
    switch (action) {
      case _WorkCardAction.edit:
      case _WorkCardAction.addPhotos:
        await context.push<bool>('/work-cards/${card.id}/edit');
      case _WorkCardAction.hide:
        final success = await controller.setHidden(card, true);
        if (mounted) {
          _showResult(success, 'Work hidden from search');
        }
      case _WorkCardAction.show:
        final success = await controller.setHidden(card, false);
        if (mounted) {
          _showResult(success, 'Work visible in search');
        }
      case _WorkCardAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete this work?'),
            content: const Text(
              'This work will no longer appear in your work list.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          final success = await controller.delete(card);
          if (mounted) {
            _showResult(success, 'Work deleted');
          }
        }
    }
  }

  void _showResult(bool success, String successMessage) {
    final state = ref.read(workCardControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : state.errorMessage ?? 'Unable to update work',
        ),
      ),
    );
  }
}

enum _WorkCardAction { edit, addPhotos, hide, show, delete }

class _OwnerWorkCard extends StatelessWidget {
  const _OwnerWorkCard({
    required this.card,
    required this.disabled,
    required this.onAction,
  });

  final WorkCardResult card;
  final bool disabled;
  final ValueChanged<_WorkCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final cover = card.photos.isEmpty
        ? null
        : card.photos.first.thumbnailUrl ?? card.photos.first.url;
    return AppCard(
      onTap: disabled ? null : () => onAction(_WorkCardAction.edit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: cover == null
                  ? const _WorkPhotoPlaceholder()
                  : Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _WorkPhotoPlaceholder(),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.displayWorkName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              PopupMenuButton<_WorkCardAction>(
                enabled: !disabled,
                tooltip: 'Work actions',
                onSelected: onAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _WorkCardAction.edit,
                    child: _MenuLabel(Icons.edit_outlined, 'Edit work'),
                  ),
                  const PopupMenuItem(
                    value: _WorkCardAction.addPhotos,
                    child: _MenuLabel(
                      Icons.add_photo_alternate_outlined,
                      'Add photos',
                    ),
                  ),
                  if (card.status == 'published')
                    const PopupMenuItem(
                      value: _WorkCardAction.hide,
                      child: _MenuLabel(
                        Icons.visibility_off_outlined,
                        'Hide work',
                      ),
                    ),
                  if (card.status == 'hidden_by_user')
                    const PopupMenuItem(
                      value: _WorkCardAction.show,
                      child: _MenuLabel(Icons.visibility_outlined, 'Show work'),
                    ),
                  const PopupMenuItem(
                    value: _WorkCardAction.delete,
                    child: _MenuLabel(Icons.delete_outline, 'Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(card.displayCategory),
          if (card.productTypes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(card.productTypes.join(', ')),
          ],
          const SizedBox(height: 12),
          _StatusChip(status: card.status),
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
      'published' => ('Published', connectTeal),
      'hidden_by_user' => ('Hidden', connectAmber),
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

class _EmptyWorkList extends StatelessWidget {
  const _EmptyWorkList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 52,
              color: connectTeal,
            ),
            const SizedBox(height: 14),
            Text(
              'Add your first work to appear in search',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkListLoading extends StatelessWidget {
  const _WorkListLoading();

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

class _WorkListError extends StatelessWidget {
  const _WorkListError({required this.message, required this.onRetry});

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

class _WorkPhotoPlaceholder extends StatelessWidget {
  const _WorkPhotoPlaceholder();

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
