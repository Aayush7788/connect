import 'dart:async';
import 'dart:typed_data';

import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/media/full_screen_media_gallery.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaUploadSummary {
  const MediaUploadSummary({
    required this.readyCount,
    required this.isBusy,
    required this.meetsMinimum,
  });

  final int readyCount;
  final bool isBusy;
  final bool meetsMinimum;
}

class MediaUploadGrid extends ConsumerStatefulWidget {
  const MediaUploadGrid({
    required this.target,
    required this.title,
    required this.existingMedia,
    super.key,
    this.disabled = false,
    this.onSummaryChanged,
    this.onMediaChanged,
  });

  final MediaTargetConfig target;
  final String title;
  final List<MediaAssetResult> existingMedia;
  final bool disabled;
  final ValueChanged<MediaUploadSummary>? onSummaryChanged;
  final Future<void> Function()? onMediaChanged;

  @override
  ConsumerState<MediaUploadGrid> createState() => _MediaUploadGridState();
}

enum _MediaPhase {
  preparing,
  uploading,
  processing,
  ready,
  failed,
  cancelling,
  deleting,
}

class _MediaTile {
  const _MediaTile({
    required this.localId,
    required this.phase,
    this.mediaAssetId,
    this.previewBytes,
    this.url,
    this.prepared,
    this.progress = 0,
    this.message,
    this.cancelToken,
  });

  final String localId;
  final String? mediaAssetId;
  final _MediaPhase phase;
  final Uint8List? previewBytes;
  final String? url;
  final PreparedMediaImage? prepared;
  final double progress;
  final String? message;
  final CancelToken? cancelToken;

  _MediaTile copyWith({
    String? mediaAssetId,
    _MediaPhase? phase,
    Uint8List? previewBytes,
    String? url,
    PreparedMediaImage? prepared,
    double? progress,
    String? message,
    CancelToken? cancelToken,
  }) {
    return _MediaTile(
      localId: localId,
      mediaAssetId: mediaAssetId ?? this.mediaAssetId,
      phase: phase ?? this.phase,
      previewBytes: previewBytes ?? this.previewBytes,
      url: url ?? this.url,
      prepared: prepared ?? this.prepared,
      progress: progress ?? this.progress,
      message: message,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}

class _MediaUploadGridState extends ConsumerState<MediaUploadGrid> {
  final List<_MediaTile> _tiles = [];
  String? _selectionError;
  bool _permissionRequired = false;
  bool _isPicking = false;
  int _localSequence = 0;

  @override
  void initState() {
    super.initState();
    _syncExisting(widget.existingMedia);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifySummary();
      unawaited(_recoverLostImages());
    });
  }

  @override
  void didUpdateWidget(covariant MediaUploadGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target.entityId != widget.target.entityId ||
        oldWidget.target.entityType != widget.target.entityType) {
      _tiles.clear();
    }
    _syncExisting(widget.existingMedia);
  }

  @override
  Widget build(BuildContext context) {
    final readyCount = _readyCount;
    final remaining = widget.target.maximumPhotos - _tiles.length;
    final canAdd = !widget.disabled && !_isPicking && !_isBusy && remaining > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          widget.target.minimumPhotos > 0
              ? 'Add at least ${widget.target.minimumPhotos} clear photos'
              : 'Add a clear photo to improve trust',
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          key: const Key('media-upload-button'),
          onPressed: canAdd ? _pickImages : null,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(_tiles.isEmpty ? 'Upload photos' : 'Add more photos'),
        ),
        const SizedBox(height: 8),
        Text('$readyCount of ${widget.target.maximumPhotos} photos added'),
        if (_selectionError != null) ...[
          const SizedBox(height: 12),
          _InlineMessage(
            icon: _permissionRequired
                ? Icons.photo_library_outlined
                : Icons.error_outline,
            message: _selectionError!,
            color: const Color(0xFFB91C1C),
          ),
          if (_permissionRequired) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(appSettingsGatewayProvider).openSettings(),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open settings'),
            ),
          ],
        ],
        if (_tiles.isNotEmpty) ...[
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) => _tile(_tiles[index]),
          ),
        ],
        if (widget.target.minimumPhotos > 0 &&
            readyCount < widget.target.minimumPhotos) ...[
          const SizedBox(height: 12),
          _InlineMessage(
            key: const Key('minimum-photo-error'),
            icon: Icons.info_outline,
            message: 'Minimum ${widget.target.minimumPhotos} photos required',
            color: connectAmber,
          ),
        ],
      ],
    );
  }

  Widget _tile(_MediaTile tile) {
    final isReady = tile.phase == _MediaPhase.ready;
    return Container(
      key: Key('media-tile-${tile.localId}'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: tile.phase == _MediaPhase.failed
              ? const Color(0xFFB91C1C)
              : connectLine,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                InkWell(
                  onTap: isReady ? () => _openGallery(tile.localId) : null,
                  child: _preview(tile),
                ),
                if (tile.phase == _MediaPhase.preparing ||
                    tile.phase == _MediaPhase.processing ||
                    tile.phase == _MediaPhase.cancelling ||
                    tile.phase == _MediaPhase.deleting)
                  Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                if (isReady && !widget.disabled)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _PhotoIconButton(
                      tooltip: 'Delete photo',
                      icon: Icons.delete_outline,
                      onPressed: () => _delete(tile),
                    ),
                  ),
              ],
            ),
          ),
          if (tile.phase == _MediaPhase.uploading) ...[
            LinearProgressIndicator(value: tile.progress),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 4, 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${(tile.progress * 100).round()}% uploading'),
                  ),
                  IconButton(
                    tooltip: 'Cancel upload',
                    onPressed: () => _cancel(tile),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          ] else if (tile.phase == _MediaPhase.failed)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 4, 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tile.message ?? 'Unable to upload, please retry',
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (tile.prepared != null)
                    IconButton(
                      tooltip: 'Retry upload',
                      onPressed: () => _retry(tile),
                      icon: const Icon(Icons.refresh, size: 20),
                    ),
                  IconButton(
                    tooltip: 'Cancel upload',
                    onPressed: () => _cancel(tile),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            )
          else if (isReady)
            const Padding(
              padding: EdgeInsets.all(9),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 17, color: connectTeal),
                  SizedBox(width: 6),
                  Text('Uploaded'),
                ],
              ),
            )
          else if (tile.phase == _MediaPhase.processing)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Checking photo...'),
            )
          else
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Preparing photo...'),
            ),
        ],
      ),
    );
  }

  Widget _preview(_MediaTile tile) {
    if (tile.previewBytes != null) {
      return Image.memory(tile.previewBytes!, fit: BoxFit.cover);
    }
    if (tile.url != null) {
      return Image.network(
        tile.url!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _PhotoPlaceholder(),
      );
    }
    return const _PhotoPlaceholder();
  }

  Future<void> _pickImages() async {
    setState(() {
      _isPicking = true;
      _selectionError = null;
      _permissionRequired = false;
    });
    try {
      final selected = await ref
          .read(mediaPickerProvider)
          .pickImages(limit: widget.target.maximumPhotos - _tiles.length);
      await _queueSelected(selected);
    } on MediaSelectionFailure catch (error) {
      if (mounted) {
        setState(() {
          _selectionError = error.message;
          _permissionRequired = error.permissionRequired;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _selectionError = 'Unable to open photos');
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _recoverLostImages() async {
    try {
      final images = await ref.read(mediaPickerProvider).recoverLostImages();
      final remaining = widget.target.maximumPhotos - _tiles.length;
      await _queueSelected(images.take(remaining).toList(growable: false));
    } on MediaSelectionFailure catch (error) {
      if (mounted) {
        setState(() {
          _selectionError = error.message;
          _permissionRequired = error.permissionRequired;
        });
      }
    }
  }

  Future<void> _queueSelected(List<SelectedMediaImage> selected) async {
    final queued = <MapEntry<String, SelectedMediaImage>>[];
    for (final image in selected) {
      final localId = 'local-${_localSequence++}';
      queued.add(MapEntry(localId, image));
      _tiles.add(
        _MediaTile(
          localId: localId,
          phase: _MediaPhase.preparing,
          previewBytes: image.bytes,
        ),
      );
    }
    if (queued.isNotEmpty && mounted) {
      setState(() {});
      _notifySummary();
    }
    for (final item in queued) {
      await _startUpload(item.key, item.value);
    }
  }

  Future<void> _startUpload(String localId, SelectedMediaImage selected) async {
    final coordinator = ref.read(mediaUploadCoordinatorProvider);
    UploadIntentResult? intent;
    try {
      final prepared = await coordinator.prepare(selected);
      if (!_contains(localId)) {
        return;
      }
      _replace(
        localId,
        _find(
          localId,
        )!.copyWith(prepared: prepared, previewBytes: prepared.bytes),
      );
      intent = await coordinator.createIntent(
        target: widget.target,
        image: prepared,
      );
      final cancelToken = CancelToken();
      _replace(
        localId,
        _find(localId)!.copyWith(
          mediaAssetId: intent.mediaAsset.id,
          phase: _MediaPhase.uploading,
          progress: 0,
          cancelToken: cancelToken,
        ),
      );
      final ready = await coordinator.uploadAndComplete(
        intent: intent,
        image: prepared,
        cancelToken: cancelToken,
        onUploaded: () {
          if (_contains(localId)) {
            _replace(
              localId,
              _find(localId)!.copyWith(phase: _MediaPhase.processing),
            );
          }
        },
        onProgress: (sent, total) {
          if (!_contains(localId) || total <= 0) {
            return;
          }
          _replace(
            localId,
            _find(localId)!.copyWith(progress: sent / total),
            notify: false,
          );
        },
      );
      if (!_contains(localId)) {
        return;
      }
      _replace(
        localId,
        _find(
          localId,
        )!.copyWith(phase: _MediaPhase.ready, progress: 1, url: ready.url),
      );
      await widget.onMediaChanged?.call();
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error)) {
        _markFailed(localId, intent?.mediaAsset.id);
      }
    } on MediaSelectionFailure catch (error) {
      _markFailed(localId, intent?.mediaAsset.id, message: error.message);
    } catch (_) {
      _markFailed(localId, intent?.mediaAsset.id);
    }
  }

  Future<void> _retry(_MediaTile tile) async {
    final mediaAssetId = tile.mediaAssetId;
    final prepared = tile.prepared;
    if (mediaAssetId == null || prepared == null) {
      return;
    }
    final coordinator = ref.read(mediaUploadCoordinatorProvider);
    try {
      final intent = await coordinator.retry(mediaAssetId);
      final cancelToken = CancelToken();
      _replace(
        tile.localId,
        tile.copyWith(
          phase: _MediaPhase.uploading,
          progress: 0,
          cancelToken: cancelToken,
        ),
      );
      final ready = await coordinator.uploadAndComplete(
        intent: intent,
        image: prepared,
        cancelToken: cancelToken,
        onUploaded: () {
          if (_contains(tile.localId)) {
            _replace(
              tile.localId,
              _find(tile.localId)!.copyWith(phase: _MediaPhase.processing),
            );
          }
        },
        onProgress: (sent, total) {
          if (!_contains(tile.localId) || total <= 0) {
            return;
          }
          _replace(
            tile.localId,
            _find(tile.localId)!.copyWith(progress: sent / total),
            notify: false,
          );
        },
      );
      if (_contains(tile.localId)) {
        _replace(
          tile.localId,
          _find(
            tile.localId,
          )!.copyWith(phase: _MediaPhase.ready, progress: 1, url: ready.url),
        );
        await widget.onMediaChanged?.call();
      }
    } catch (_) {
      _markFailed(tile.localId, mediaAssetId);
    }
  }

  Future<void> _cancel(_MediaTile tile) async {
    tile.cancelToken?.cancel('User cancelled upload');
    _replace(tile.localId, tile.copyWith(phase: _MediaPhase.cancelling));
    try {
      if (tile.mediaAssetId != null) {
        await ref
            .read(mediaUploadCoordinatorProvider)
            .cancel(tile.mediaAssetId!);
      }
      _remove(tile.localId);
      await widget.onMediaChanged?.call();
    } on ApiFailure catch (error) {
      _markFailed(tile.localId, tile.mediaAssetId, message: error.message);
    }
  }

  Future<void> _delete(_MediaTile tile) async {
    if (tile.mediaAssetId == null) {
      return;
    }
    _replace(tile.localId, tile.copyWith(phase: _MediaPhase.deleting));
    try {
      await ref.read(mediaUploadCoordinatorProvider).delete(tile.mediaAssetId!);
      _remove(tile.localId);
      await widget.onMediaChanged?.call();
    } on ApiFailure catch (error) {
      _replace(tile.localId, tile.copyWith(phase: _MediaPhase.ready));
      if (mounted) {
        setState(() => _selectionError = error.message);
      }
    }
  }

  void _openGallery(String localId) {
    final ready = _tiles
        .where(
          (tile) =>
              tile.phase == _MediaPhase.ready &&
              (tile.previewBytes != null || tile.url != null),
        )
        .toList(growable: false);
    final initialIndex = ready.indexWhere((tile) => tile.localId == localId);
    if (ready.isEmpty || initialIndex < 0) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FullScreenMediaGallery(
          initialIndex: initialIndex,
          images: ready
              .map(
                (tile) => GalleryImage(bytes: tile.previewBytes, url: tile.url),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  void _syncExisting(List<MediaAssetResult> media) {
    final existingIds = _tiles
        .map((tile) => tile.mediaAssetId)
        .whereType<String>()
        .toSet();
    final additions =
        media
            .where(
              (asset) =>
                  asset.mediaKind == 'image' &&
                  asset.visibility == 'public' &&
                  asset.documentType == widget.target.documentType &&
                  !existingIds.contains(asset.id),
            )
            .toList(growable: false)
          ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    for (final asset in additions) {
      _tiles.add(
        _MediaTile(
          localId: 'server-${asset.id}',
          mediaAssetId: asset.id,
          phase: asset.uploadStatus == 'ready'
              ? _MediaPhase.ready
              : _MediaPhase.failed,
          url: asset.url,
          message: asset.uploadStatus == 'ready'
              ? null
              : 'Unable to upload, please retry',
        ),
      );
    }
  }

  void _markFailed(
    String localId,
    String? mediaAssetId, {
    String message = 'Unable to upload, please retry',
  }) {
    final tile = _find(localId);
    if (tile == null) {
      return;
    }
    _replace(
      localId,
      tile.copyWith(
        mediaAssetId: mediaAssetId,
        phase: _MediaPhase.failed,
        message: message,
      ),
    );
  }

  void _replace(String localId, _MediaTile replacement, {bool notify = true}) {
    final index = _tiles.indexWhere((tile) => tile.localId == localId);
    if (index < 0 || !mounted) {
      return;
    }
    setState(() => _tiles[index] = replacement);
    if (notify) {
      _notifySummary();
    }
  }

  void _remove(String localId) {
    if (!mounted) {
      return;
    }
    setState(() => _tiles.removeWhere((tile) => tile.localId == localId));
    _notifySummary();
  }

  _MediaTile? _find(String localId) {
    for (final tile in _tiles) {
      if (tile.localId == localId) {
        return tile;
      }
    }
    return null;
  }

  bool _contains(String localId) => _find(localId) != null;

  int get _readyCount =>
      _tiles.where((tile) => tile.phase == _MediaPhase.ready).length;

  bool get _isBusy => _tiles.any(
    (tile) => {
      _MediaPhase.preparing,
      _MediaPhase.uploading,
      _MediaPhase.processing,
      _MediaPhase.cancelling,
      _MediaPhase.deleting,
    }.contains(tile.phase),
  );

  void _notifySummary() {
    final callback = widget.onSummaryChanged;
    if (callback == null) {
      return;
    }
    final summary = MediaUploadSummary(
      readyCount: _readyCount,
      isBusy: _isBusy,
      meetsMinimum: _readyCount >= widget.target.minimumPhotos,
    );
    scheduleMicrotask(() {
      if (mounted) {
        callback(summary);
      }
    });
  }
}

class _PhotoIconButton extends StatelessWidget {
  const _PhotoIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF1F5F1),
      child: Center(
        child: Icon(Icons.image_outlined, size: 42, color: Color(0xFF64748B)),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String message;
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
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
