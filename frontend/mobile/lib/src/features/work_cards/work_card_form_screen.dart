import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/work_card_models.dart';
import 'package:connect_app/src/features/media/media_upload_grid.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/features/work_cards/work_card_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkCardFormScreen extends ConsumerStatefulWidget {
  const WorkCardFormScreen({super.key, this.workCardId});

  final String? workCardId;

  @override
  ConsumerState<WorkCardFormScreen> createState() => _WorkCardFormScreenState();
}

class _WorkCardFormScreenState extends ConsumerState<WorkCardFormScreen> {
  static const _other = '__other__';

  final _customCategory = TextEditingController();
  final _customWorkName = TextEditingController();
  final _customProduct = TextEditingController();
  final _description = TextEditingController();
  final Set<String> _productTypeIds = {};
  final Map<String, String> _localErrors = {};

  WorkCardResult? _card;
  String? _categorySelection;
  String? _workNameSelection;
  bool _customProductSelected = false;
  bool _initializing = true;
  String? _initializationError;
  MediaUploadSummary? _mediaSummary;
  late final String _draftIdempotencyKey =
      'mobile-${DateTime.now().microsecondsSinceEpoch}';

  bool get _isEditing => widget.workCardId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _customCategory.dispose();
    _customWorkName.dispose();
    _customProduct.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workCardControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(_isEditing ? 'Edit Work' : 'Add Work'),
      ),
      body: SafeArea(child: _body(state)),
      bottomNavigationBar: _card == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: connectLine)),
                ),
                child: PrimaryActionButton(
                  label: _card!.status == 'draft'
                      ? 'Save and Publish'
                      : 'Save changes',
                  isLoading: state.isSaving,
                  onPressed: _mediaSummary?.isBusy == true ? null : _submit,
                ),
              ),
            ),
    );
  }

  Widget _body(WorkCardState state) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_card == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                _initializationError ?? "Can't access internet",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _initialize,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final categoryOptions = state.taxonomy['work_category'] ?? const [];
    final workOptions = (state.taxonomy['work_name'] ?? const [])
        .where(
          (option) =>
              option.parentId == null || option.parentId == _categorySelection,
        )
        .toList(growable: false);
    final productOptions = state.taxonomy['product_type'] ?? const [];
    final serverErrors = state.fieldErrors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Show the work you do',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text('Add clear details so businesses can find this work.'),
          const SizedBox(height: 24),
          _dropdown(
            label: 'Category',
            placeholder: 'Select work category',
            value: _categorySelection,
            options: categoryOptions,
            errorText:
                _localErrors['category_id'] ?? serverErrors['category_id'],
            onChanged: (value) {
              setState(() {
                _categorySelection = value;
                _workNameSelection = null;
                _localErrors.remove('category_id');
              });
            },
          ),
          if (_categorySelection == _other) ...[
            const SizedBox(height: 14),
            _field(
              label: 'Type category',
              placeholder: 'Example: Decorative hand work',
              controller: _customCategory,
              errorText: _localErrors['custom_category_text'],
            ),
          ],
          const SizedBox(height: 18),
          _dropdown(
            label: 'Work name',
            placeholder: 'Select work name',
            value: _workNameSelection,
            options: workOptions,
            errorText:
                _localErrors['work_name_id'] ?? serverErrors['work_name_id'],
            onChanged: _categorySelection == null
                ? null
                : (value) {
                    setState(() {
                      _workNameSelection = value;
                      _localErrors.remove('work_name_id');
                    });
                  },
          ),
          if (_workNameSelection == _other) ...[
            const SizedBox(height: 14),
            _field(
              label: 'Type work name',
              placeholder: 'Example: Zari hand work',
              controller: _customWorkName,
              errorText: _localErrors['custom_work_name'],
            ),
          ],
          const SizedBox(height: 22),
          Text('Product type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Select all products this work is suitable for'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...productOptions.map(
                (option) => FilterChip(
                  label: Text(option.name),
                  selected: _productTypeIds.contains(option.id),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _productTypeIds.add(option.id)
                          : _productTypeIds.remove(option.id);
                      _localErrors.remove('product_type_ids');
                    });
                  },
                ),
              ),
              FilterChip(
                label: const Text('Other'),
                selected: _customProductSelected,
                onSelected: (selected) {
                  setState(() {
                    _customProductSelected = selected;
                    _localErrors.remove('product_type_ids');
                  });
                },
              ),
            ],
          ),
          if (_localErrors['product_type_ids'] != null ||
              serverErrors['product_type_ids'] != null) ...[
            const SizedBox(height: 6),
            Text(
              _localErrors['product_type_ids'] ??
                  serverErrors['product_type_ids']!,
              style: const TextStyle(color: Color(0xFFB91C1C)),
            ),
          ],
          if (_customProductSelected) ...[
            const SizedBox(height: 14),
            _field(
              label: 'Type product',
              placeholder: 'Example: Dupatta',
              controller: _customProduct,
              errorText: _localErrors['custom_product_texts'],
            ),
          ],
          const SizedBox(height: 24),
          MediaUploadGrid(
            target: MediaTargetConfig(
              entityType: 'work_card',
              entityId: _card!.id,
              documentType: 'work_photo',
              minimumPhotos: 3,
              maximumPhotos: 10,
            ),
            title: 'Work photos',
            existingMedia: _card!.photos,
            disabled: state.isSaving,
            onSummaryChanged: (summary) => _mediaSummary = summary,
            onMediaChanged: _reloadCard,
          ),
          const SizedBox(height: 24),
          _field(
            label: 'Description',
            placeholder: 'Describe the work, finish and suitable products',
            controller: _description,
            maxLines: 4,
            errorText:
                _localErrors['description'] ?? serverErrors['description'],
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Color(0xFF991B1B)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _initialize() async {
    setState(() {
      _initializing = true;
      _initializationError = null;
    });
    final controller = ref.read(workCardControllerProvider.notifier);
    await controller.load();
    WorkCardResult? card;
    if (widget.workCardId == null) {
      card = await controller.createDraft(_draftIdempotencyKey);
    } else {
      card = controller.find(widget.workCardId!);
    }
    if (!mounted) {
      return;
    }
    if (card == null) {
      setState(() {
        _initializing = false;
        _initializationError =
            ref.read(workCardControllerProvider).errorMessage ??
            'This work is unavailable';
      });
      return;
    }
    _loadFields(card);
    setState(() {
      _card = card;
      _initializing = false;
      _mediaSummary = MediaUploadSummary(
        readyCount: card!.photoCount,
        isBusy: false,
        meetsMinimum: card.photoCount >= 3,
      );
    });
  }

  void _loadFields(WorkCardResult card) {
    _categorySelection =
        card.categoryId ?? (card.customCategoryText == null ? null : _other);
    _customCategory.text = card.customCategoryText ?? '';
    _workNameSelection =
        card.workNameId ?? (card.customWorkName == null ? null : _other);
    _customWorkName.text = card.customWorkName ?? '';
    _productTypeIds
      ..clear()
      ..addAll(card.productTypeIds);
    _customProductSelected = card.customProductTexts.isNotEmpty;
    _customProduct.text = card.customProductTexts.join(', ');
    _description.text = card.description ?? '';
  }

  Future<void> _reloadCard() async {
    await ref.read(workCardControllerProvider.notifier).refreshCards();
    if (!mounted || _card == null) {
      return;
    }
    final updated = ref
        .read(workCardControllerProvider.notifier)
        .find(_card!.id);
    if (updated != null) {
      setState(() => _card = updated);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    ref.read(workCardControllerProvider.notifier).clearError();
    if (!_validate()) {
      return;
    }
    final customProducts = _customProductSelected
        ? _customProduct.text
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(growable: false)
        : <String>[];
    final fields = WorkCardUpsert(
      categoryId: _categorySelection == _other ? null : _categorySelection,
      customCategoryText: _categorySelection == _other
          ? _customCategory.text.trim()
          : null,
      workNameId: _workNameSelection == _other ? null : _workNameSelection,
      customWorkName: _workNameSelection == _other
          ? _customWorkName.text.trim()
          : null,
      productTypeIds: _productTypeIds.toList(growable: false),
      customProductTexts: customProducts,
      description: _description.text.trim(),
    );
    final success = await ref
        .read(workCardControllerProvider.notifier)
        .saveAndPublish(
          id: _card!.id,
          fields: fields,
          publish: _card!.status == 'draft',
        );
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  bool _validate() {
    final errors = <String, String>{};
    if (_categorySelection == null) {
      errors['category_id'] = 'Select a category';
    } else if (_categorySelection == _other &&
        _customCategory.text.trim().isEmpty) {
      errors['custom_category_text'] = 'Type the category';
    }
    if (_workNameSelection == null) {
      errors['work_name_id'] = 'Select a work name';
    } else if (_workNameSelection == _other &&
        _customWorkName.text.trim().isEmpty) {
      errors['custom_work_name'] = 'Type the work name';
    }
    if (_productTypeIds.isEmpty && !_customProductSelected) {
      errors['product_type_ids'] = 'Select at least one product type';
    }
    if (_customProductSelected && _customProduct.text.trim().isEmpty) {
      errors['custom_product_texts'] = 'Type the product';
    }
    if ((_mediaSummary?.readyCount ?? _card!.photoCount) < 3) {
      errors['photos'] = 'Minimum 3 photos required';
    }
    if (_description.text.trim().isEmpty) {
      errors['description'] = 'Enter a description';
    }
    setState(() {
      _localErrors
        ..clear()
        ..addAll(errors);
    });
    if (errors.containsKey('photos')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errors['photos']!)));
    }
    return errors.isEmpty;
  }

  Widget _dropdown({
    required String label,
    required String placeholder,
    required String? value,
    required List<CategoryOption> options,
    required ValueChanged<String?>? onChanged,
    String? errorText,
  }) {
    final validValue =
        value == _other || options.any((option) => option.id == value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: validValue ? value : null,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorText,
          ),
          isExpanded: true,
          items: [
            ...options.map(
              (option) =>
                  DropdownMenuItem(value: option.id, child: Text(option.name)),
            ),
            const DropdownMenuItem(value: _other, child: Text('Other')),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    String? errorText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLines > 1 ? 2000 : 160,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorText,
          ),
          onChanged: (_) => setState(() {
            _localErrors.removeWhere(
              (key, value) =>
                  key == 'custom_category_text' ||
                  key == 'custom_work_name' ||
                  key == 'custom_product_texts' ||
                  key == 'description',
            );
          }),
        ),
      ],
    );
  }
}
