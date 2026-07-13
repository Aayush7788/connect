import 'dart:async';

import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/features/media/media_upload_grid.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:connect_app/src/features/profile/profile_display.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _ownerName = TextEditingController();
  final _alternateContact = TextEditingController();
  final _fullAddress = TextEditingController();
  final _locality = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController(text: 'Gujarat');
  final _pincode = TextEditingController();
  final _businessName = TextEditingController();
  final _manufactureSell = TextEditingController();
  final _customProduct = TextEditingController();
  final _workshopName = TextEditingController();
  final _workSummary = TextEditingController();
  final _skillMastery = TextEditingController();
  final _experience = TextEditingController();
  final _bio = TextEditingController();

  Timer? _autoSaveTimer;
  bool _initialized = false;
  bool _hasWorkshop = true;
  int _step = 0;
  String? _businessCategoryId;
  String? _skillCategoryId;
  final Set<String> _productTypeIds = {};
  bool _savedOnce = false;
  MediaUploadSummary? _mediaSummary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    for (final controller in [
      _ownerName,
      _alternateContact,
      _fullAddress,
      _locality,
      _city,
      _state,
      _pincode,
      _businessName,
      _manufactureSell,
      _customProduct,
      _workshopName,
      _workSummary,
      _skillMastery,
      _experience,
      _bio,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final ownerProfile = state.profile;
    if (state.isLoading && ownerProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (ownerProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complete Profile')),
        body: Center(
          child: OutlinedButton.icon(
            onPressed: () =>
                ref.read(profileControllerProvider.notifier).load(force: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      );
    }
    if (!_initialized) {
      _initialize(ownerProfile);
    }
    final role = ownerProfile.profile.role;
    final pending = ownerProfile.profile.verificationStatus == 'pending';
    final ownerLocked = ownerProfile.lockedFields.contains('owner_name');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Complete Profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_step + 1) / 4,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Step ${_step + 1} of 4'),
                      const Spacer(),
                      if (state.isSaving)
                        const Text('Saving...')
                      else if (_savedOnce)
                        const Row(
                          children: [
                            Icon(Icons.check, size: 16, color: connectTeal),
                            SizedBox(width: 4),
                            Text('Saved'),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: switch (_step) {
                  0 => _detailsStep(
                    role: role,
                    ownerLocked: ownerLocked,
                    disabled: pending,
                    state: state,
                  ),
                  1 => _addressStep(disabled: pending, state: state),
                  2 => _photoStep(ownerProfile, disabled: pending),
                  _ => _reviewStep(ownerProfile),
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: connectLine)),
              ),
              child: Column(
                children: [
                  if (state.errorMessage != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Color(0xFFB91C1C)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_step < 3)
                    PrimaryActionButton(
                      label: 'Next',
                      isLoading: state.isSaving,
                      onPressed: pending || (_mediaSummary?.isBusy ?? false)
                          ? null
                          : _next,
                    )
                  else
                    PrimaryActionButton(
                      label: 'Done',
                      isLoading: state.isSaving,
                      onPressed: pending ? null : _complete,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => setState(() => _step -= 1),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                        ),
                      Expanded(
                        child: TextButton(
                          onPressed: pending ? null : _saveAndExit,
                          child: const Text('Save and exit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsStep({
    required String role,
    required bool ownerLocked,
    required bool disabled,
    required ProfileState state,
  }) {
    final categoryOptions = state.categories['business_category'] ?? const [];
    final productOptions = state.categories['product_type'] ?? const [];
    final skillOptions = state.categories['work_name'] ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profileRoleLabel(role),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 18),
        if (role == 'business') ...[
          _field(
            label: 'Business name',
            placeholder: 'Enter business name',
            controller: _businessName,
            disabled: disabled,
            errorText: state.fieldErrors['business_name'],
          ),
          _field(
            label: 'What do you manufacture or sell?',
            placeholder: 'Example: Dupattas and dress material',
            controller: _manufactureSell,
            disabled: disabled,
            maxLines: 3,
            errorText: state.fieldErrors['manufacture_sell_details'],
          ),
          _dropdown(
            label: 'Business category',
            value: _businessCategoryId,
            options: categoryOptions,
            disabled: disabled,
            onChanged: (value) {
              setState(() => _businessCategoryId = value);
              _scheduleAutoSave();
            },
          ),
          _ProductTypeSelector(
            options: productOptions,
            selectedIds: _productTypeIds,
            disabled: disabled,
            onChanged: (values) {
              setState(() {
                _productTypeIds
                  ..clear()
                  ..addAll(values);
              });
              _scheduleAutoSave();
            },
          ),
          _field(
            label: 'Other product type',
            placeholder: 'Type product if not listed',
            controller: _customProduct,
            disabled: disabled,
          ),
        ] else if (role == 'job_worker') ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('I work from a workshop'),
            value: _hasWorkshop,
            onChanged: disabled
                ? null
                : (value) {
                    setState(() => _hasWorkshop = value);
                    _scheduleAutoSave();
                  },
          ),
          if (_hasWorkshop)
            _field(
              label: 'Workshop name',
              placeholder: 'Enter workshop name',
              controller: _workshopName,
              disabled: disabled,
              errorText: state.fieldErrors['workshop_name'],
            ),
          _field(
            label: 'What work do you do?',
            placeholder: 'Example: Flat hemming and overlock',
            controller: _workSummary,
            disabled: disabled,
            maxLines: 3,
          ),
        ] else ...[
          _dropdown(
            label: 'Primary skill',
            value: _skillCategoryId,
            options: skillOptions,
            disabled: disabled,
            onChanged: (value) {
              setState(() => _skillCategoryId = value);
              _scheduleAutoSave();
            },
          ),
          _field(
            label: 'Skill details',
            placeholder: 'Describe the work you have mastery in',
            controller: _skillMastery,
            disabled: disabled,
            maxLines: 3,
            errorText: state.fieldErrors['skill_mastery'],
          ),
          _field(
            label: 'Experience in years',
            placeholder: 'Example: 4',
            controller: _experience,
            disabled: disabled,
            keyboardType: TextInputType.number,
            errorText: state.fieldErrors['experience_years'],
          ),
          _field(
            label: 'About your work',
            placeholder: 'Optional',
            controller: _bio,
            disabled: disabled,
            maxLines: 3,
          ),
        ],
        _field(
          label: role == 'skilled_worker' ? 'Name' : 'Owner name',
          placeholder: 'Enter name',
          controller: _ownerName,
          disabled: disabled || ownerLocked,
          errorText: state.fieldErrors['owner_name'],
        ),
        _field(
          label: 'Mobile number',
          placeholder:
              ref.watch(authControllerProvider).me?.user.primaryMobile ?? '',
          readOnlyValue:
              ref.watch(authControllerProvider).me?.user.primaryMobile ?? '',
        ),
        _field(
          label: 'Alternate contact number',
          placeholder: 'Optional',
          controller: _alternateContact,
          disabled: disabled,
          keyboardType: TextInputType.phone,
          errorText: state.fieldErrors['alternate_contact_number'],
        ),
      ],
    );
  }

  Widget _addressStep({required bool disabled, required ProfileState state}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Work address', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
        _field(
          label: 'Full address',
          placeholder: 'Shop, building, street and landmark',
          controller: _fullAddress,
          disabled: disabled,
          maxLines: 3,
          errorText: state.fieldErrors['full_address'],
        ),
        _field(
          label: 'Area / locality',
          placeholder: 'Example: Ring Road',
          controller: _locality,
          disabled: disabled,
          errorText: state.fieldErrors['locality'],
        ),
        _field(
          label: 'City',
          placeholder: 'Example: Surat',
          controller: _city,
          disabled: disabled,
          errorText: state.fieldErrors['city'],
        ),
        _field(
          label: 'State',
          placeholder: 'Example: Gujarat',
          controller: _state,
          disabled: disabled,
          errorText: state.fieldErrors['state'],
        ),
        _field(
          label: 'Pincode',
          placeholder: '6 digit pincode',
          controller: _pincode,
          disabled: disabled,
          keyboardType: TextInputType.number,
          errorText: state.fieldErrors['pincode'],
        ),
      ],
    );
  }

  Widget _reviewStep(OwnerProfileResult ownerProfile) {
    final missing = ownerProfile.profile.completionFlags.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review profile', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ownerProfile.profile.displayName ?? 'Your profile',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${ownerProfile.profile.completionScore}%',
                    style: const TextStyle(
                      color: connectTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: ownerProfile.profile.completionScore / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
        if (missing.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Still required',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...missing.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: connectAmber,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(completionItemLabel(field))),
                ],
              ),
            ),
          ),
          if (ownerProfile.profile.role == 'job_worker' &&
              missing.contains('published_work_card')) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoute.addWorkCard.path),
              icon: const Icon(Icons.add),
              label: const Text('Add work'),
            ),
          ],
        ] else ...[
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: connectTeal),
              SizedBox(width: 10),
              Text('Profile details complete'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _photoStep(OwnerProfileResult ownerProfile, {required bool disabled}) {
    final role = ownerProfile.profile.role;
    final minimumPhotos = role == 'skilled_worker' ? 0 : 3;
    final documentType = switch (role) {
      'business' => 'shop_photo',
      'job_worker' => 'workplace_photo',
      _ => 'other',
    };
    final title = switch (role) {
      'business' => 'Shop photos',
      'job_worker' => 'Workplace photos',
      _ => 'Your photo',
    };
    return MediaUploadGrid(
      target: MediaTargetConfig(
        entityType: 'profile',
        entityId: ownerProfile.profile.id,
        documentType: documentType,
        minimumPhotos: minimumPhotos,
      ),
      title: title,
      existingMedia: ownerProfile.media,
      disabled: disabled,
      onSummaryChanged: (summary) {
        if (!mounted) {
          return;
        }
        setState(() => _mediaSummary = summary);
      },
      onMediaChanged: () {
        return ref.read(profileControllerProvider.notifier).load(force: true);
      },
    );
  }

  Widget _field({
    required String label,
    required String placeholder,
    TextEditingController? controller,
    bool disabled = false,
    String? readOnlyValue,
    String? errorText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          if (readOnlyValue != null)
            InputDecorator(
              decoration: InputDecoration(hintText: placeholder),
              child: Text(readOnlyValue),
            )
          else
            TextField(
              controller: controller,
              enabled: !disabled,
              maxLines: maxLines,
              keyboardType: keyboardType,
              onChanged: (_) => _scheduleAutoSave(),
              decoration: InputDecoration(
                hintText: placeholder,
                errorText: errorText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<CategoryOption> options,
    required bool disabled,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            initialValue: options.any((option) => option.id == value)
                ? value
                : null,
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option.id,
                    child: Text(option.name),
                  ),
                )
                .toList(growable: false),
            onChanged: disabled ? null : onChanged,
            decoration: const InputDecoration(hintText: 'Select'),
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  void _initialize(OwnerProfileResult ownerProfile) {
    final details = ownerProfile.roleSpecific;
    _ownerName.text = details['owner_name']?.toString() ?? '';
    _alternateContact.text =
        details['alternate_contact_number']?.toString() ?? '';
    _fullAddress.text = details['full_address']?.toString() ?? '';
    _locality.text = details['locality']?.toString() ?? '';
    _city.text = details['city']?.toString() ?? '';
    _state.text = details['state']?.toString() ?? 'Gujarat';
    _pincode.text = details['pincode']?.toString() ?? '';
    _businessName.text = details['business_name']?.toString() ?? '';
    _businessCategoryId = details['business_category_id']?.toString();
    _manufactureSell.text =
        details['manufacture_sell_details']?.toString() ?? '';
    _workshopName.text = details['workshop_name']?.toString() ?? '';
    _hasWorkshop = details['has_workshop'] as bool? ?? true;
    _workSummary.text = details['work_summary']?.toString() ?? '';
    _skillCategoryId = details['primary_skill_category_id']?.toString();
    _skillMastery.text = details['skill_mastery']?.toString() ?? '';
    _experience.text = details['experience_years']?.toString() ?? '';
    _bio.text = details['bio']?.toString() ?? '';
    final products = details['product_types'] as List<dynamic>? ?? [];
    for (final product in products) {
      final values = product as Map<String, dynamic>;
      final categoryId = values['category_id']?.toString();
      final custom = values['custom_text']?.toString();
      if (categoryId != null) {
        _productTypeIds.add(categoryId);
      }
      if (custom != null && custom.isNotEmpty) {
        _customProduct.text = custom;
      }
    }
    _initialized = true;
  }

  Map<String, dynamic> _payload() {
    final profile = ref.read(profileControllerProvider).profile!;
    final role = profile.profile.role;
    final fields = <String, dynamic>{
      'owner_name': _value(_ownerName),
      'alternate_contact_number': _value(_alternateContact),
      'full_address': _value(_fullAddress),
      'locality': _value(_locality),
      'city': _value(_city),
      'state': _value(_state),
      'pincode': _value(_pincode),
    };
    if (role == 'business') {
      fields.addAll({
        'business_name': _value(_businessName),
        'business_category_id': _businessCategoryId,
        'manufacture_sell_details': _value(_manufactureSell),
        'product_type_ids': _productTypeIds.toList(growable: false),
        'custom_product_types': _value(_customProduct) == null
            ? <String>[]
            : [_value(_customProduct)],
      });
    } else if (role == 'job_worker') {
      fields.addAll({
        'workshop_name': _hasWorkshop ? _value(_workshopName) : null,
        'has_workshop': _hasWorkshop,
        'work_summary': _value(_workSummary),
      });
    } else {
      fields.addAll({
        'primary_skill_category_id': _skillCategoryId,
        'skill_mastery': _value(_skillMastery),
        'experience_years': int.tryParse(_experience.text.trim()),
        'bio': _value(_bio),
      });
    }
    if (profile.lockedFields.contains('owner_name')) {
      fields.remove('owner_name');
    }
    return fields;
  }

  String? _value(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _scheduleAutoSave() {
    if (!_initialized) {
      return;
    }
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 900), () async {
      if (!mounted) {
        return;
      }
      if (ref.read(profileControllerProvider).isSaving) {
        _scheduleAutoSave();
        return;
      }
      await _saveDraft();
    });
  }

  Future<bool> _saveDraft() async {
    _autoSaveTimer?.cancel();
    final saved = await ref
        .read(profileControllerProvider.notifier)
        .save(_payload());
    if (mounted && saved) {
      setState(() => _savedOnce = true);
    }
    return saved;
  }

  Future<void> _next() async {
    if (_step == 2) {
      final role = ref.read(profileControllerProvider).profile?.profile.role;
      if (role != 'skilled_worker' && _mediaSummary?.meetsMinimum != true) {
        return;
      }
    }
    if (await _saveDraft() && mounted) {
      setState(() => _step += 1);
    }
  }

  Future<void> _saveAndExit() async {
    if (await _saveDraft() && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _complete() async {
    if (!await _saveDraft()) {
      return;
    }
    final complete = await ref
        .read(profileControllerProvider.notifier)
        .complete();
    if (complete && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _ProductTypeSelector extends StatelessWidget {
  const _ProductTypeSelector({
    required this.options,
    required this.selectedIds,
    required this.disabled,
    required this.onChanged,
  });

  final List<CategoryOption> options;
  final Set<String> selectedIds;
  final bool disabled;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = options
        .where((option) => selectedIds.contains(option.id))
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product type',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          OutlinedButton.icon(
            onPressed: disabled
                ? null
                : () async {
                    final result = await showModalBottomSheet<Set<String>>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => _ProductTypeSheet(
                        options: options,
                        selectedIds: selectedIds,
                      ),
                    );
                    if (result != null) {
                      onChanged(result);
                    }
                  },
            icon: const Icon(Icons.checklist_outlined),
            label: const Text('Select product types'),
          ),
          if (selected.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected
                  .map(
                    (option) => InputChip(
                      label: Text(option.name),
                      onDeleted: disabled
                          ? null
                          : () {
                              final values = Set<String>.from(selectedIds)
                                ..remove(option.id);
                              onChanged(values);
                            },
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductTypeSheet extends StatefulWidget {
  const _ProductTypeSheet({required this.options, required this.selectedIds});

  final List<CategoryOption> options;
  final Set<String> selectedIds;

  @override
  State<_ProductTypeSheet> createState() => _ProductTypeSheetState();
}

class _ProductTypeSheetState extends State<_ProductTypeSheet> {
  late final Set<String> _selected = Set<String>.from(widget.selectedIds);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product types',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.options
                    .map(
                      (option) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.name),
                        value: _selected.contains(option.id),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selected.add(option.id);
                            } else {
                              _selected.remove(option.id);
                            }
                          });
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryActionButton(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }
}
