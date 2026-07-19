import 'dart:async';

import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/features/auth/auth_controller.dart';
import 'package:connect_app/src/features/media/media_upload_grid.dart';
import 'package:connect_app/src/features/media/media_upload_service.dart';
import 'package:connect_app/src/features/profile/profile_controller.dart';
import 'package:connect_app/src/features/profile/profile_display.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  static const _otherProductTypeId = '__other_product_type__';
  static const _otherSkillId = '__other_skill__';

  final _ownerName = TextEditingController();
  final _alternateContact = TextEditingController();
  final _addressLine1 = TextEditingController();
  final _locality = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _businessName = TextEditingController();
  final _customBusinessCategory = TextEditingController();
  final _manufactureSell = TextEditingController();
  final _customProduct = TextEditingController();
  final _workshopName = TextEditingController();
  final _workSummary = TextEditingController();
  final _customSkill = TextEditingController();
  final _skillMastery = TextEditingController();
  final _experience = TextEditingController();
  final _bio = TextEditingController();

  Timer? _autoSaveTimer;
  Timer? _pincodeValidationTimer;
  bool _initialized = false;
  bool _hasWorkshop = true;
  int _step = 0;
  String? _businessCategoryId;
  final Set<String> _skillCategoryIds = {};
  bool _otherSkillSelected = false;
  final Set<String> _productTypeIds = {};
  bool _otherProductSelected = false;
  bool _savedOnce = false;
  bool _isSubmitting = false;
  Future<bool>? _saveFuture;
  Map<String, dynamic> _lastPersistedPayload = const {};
  MediaUploadSummary? _mediaSummary;
  List<LocationOption> _states = const [];
  List<LocationOption> _districts = const [];
  LocationOption? _selectedState;
  LocationOption? _selectedDistrict;
  AddressValidationResult? _addressValidation;
  bool _loadingStates = false;
  bool _loadingDistricts = false;
  bool _validatingAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).load();
      unawaited(_loadStates());
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _pincodeValidationTimer?.cancel();
    for (final controller in [
      _ownerName,
      _alternateContact,
      _addressLine1,
      _locality,
      _city,
      _state,
      _pincode,
      _businessName,
      _customBusinessCategory,
      _manufactureSell,
      _customProduct,
      _workshopName,
      _workSummary,
      _customSkill,
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
                      isLoading: _isSubmitting,
                      onPressed:
                          pending ||
                              _isSubmitting ||
                              (_mediaSummary?.isBusy ?? false)
                          ? null
                          : _next,
                    )
                  else
                    PrimaryActionButton(
                      label: 'Complete and publish',
                      isLoading: _isSubmitting,
                      onPressed: pending || _isSubmitting ? null : _complete,
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
    final primaryMobile =
        ref.watch(authControllerProvider).me?.user.primaryMobile ?? '';
    final productSelectorOptions = [
      ...productOptions,
      const CategoryOption(
        id: _otherProductTypeId,
        categoryType: 'product_type',
        name: 'Other',
      ),
    ];
    final skillSelectorOptions = [
      ...skillOptions,
      const CategoryOption(
        id: _otherSkillId,
        categoryType: 'work_name',
        name: 'Other',
      ),
    ];
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
            label: 'Owner name',
            placeholder: 'Enter owner name',
            controller: _ownerName,
            disabled: disabled || ownerLocked,
            errorText: state.fieldErrors['owner_name'],
          ),
          _field(
            label: 'Mobile number',
            placeholder: primaryMobile,
            readOnlyValue: primaryMobile,
          ),
          _field(
            label: 'Business name',
            placeholder: 'Enter business name',
            controller: _businessName,
            disabled: disabled,
            errorText: state.fieldErrors['business_name'],
          ),
          _dropdown(
            label: 'Business category',
            value: _businessCategoryId,
            options: categoryOptions,
            disabled: disabled,
            onChanged: (value) {
              setState(() {
                _businessCategoryId = value;
                if (!_isOtherBusinessCategory(categoryOptions)) {
                  _customBusinessCategory.clear();
                }
              });
              _scheduleAutoSave();
            },
          ),
          if (_isOtherBusinessCategory(categoryOptions))
            _field(
              label: 'Other business category',
              placeholder: 'Enter your business category',
              controller: _customBusinessCategory,
              disabled: disabled,
              errorText: state.fieldErrors['custom_business_category'],
            ),
          _MultiCategorySelector(
            label: 'Product type',
            buttonLabel: 'Select product types',
            sheetTitle: 'Product types',
            options: productSelectorOptions,
            selectedIds: {
              ..._productTypeIds,
              if (_otherProductSelected) _otherProductTypeId,
            },
            disabled: disabled,
            onChanged: (values) {
              final selected = Set<String>.from(values);
              final otherSelected = selected.remove(_otherProductTypeId);
              setState(() {
                _productTypeIds
                  ..clear()
                  ..addAll(selected);
                _otherProductSelected = otherSelected;
                if (!otherSelected) {
                  _customProduct.clear();
                }
              });
              _scheduleAutoSave();
            },
          ),
          if (_otherProductSelected)
            _field(
              label: 'Other product category',
              placeholder: 'Enter your product category',
              controller: _customProduct,
              disabled: disabled,
            ),
          _field(
            label: 'Optional phone number',
            placeholder: 'Enter another contact number',
            controller: _alternateContact,
            disabled: disabled,
            keyboardType: TextInputType.phone,
            errorText: state.fieldErrors['alternate_contact_number'],
          ),
          _field(
            label: 'What do you manufacture or sell?',
            placeholder: 'Example: Dupattas and dress material',
            controller: _manufactureSell,
            disabled: disabled,
            maxLines: 3,
            errorText: state.fieldErrors['manufacture_sell_details'],
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
          _field(
            label: 'Owner name',
            placeholder: 'Enter name',
            controller: _ownerName,
            disabled: disabled || ownerLocked,
            errorText: state.fieldErrors['owner_name'],
          ),
          _field(
            label: 'Mobile number',
            placeholder: primaryMobile,
            readOnlyValue: primaryMobile,
          ),
          _field(
            label: 'Alternate contact number',
            placeholder: 'Optional',
            controller: _alternateContact,
            disabled: disabled,
            keyboardType: TextInputType.phone,
            errorText: state.fieldErrors['alternate_contact_number'],
          ),
        ] else ...[
          _field(
            label: 'Name',
            placeholder: 'Enter name',
            controller: _ownerName,
            disabled: disabled || ownerLocked,
            errorText: state.fieldErrors['owner_name'],
          ),
          _field(
            label: 'Mobile number',
            placeholder: primaryMobile,
            readOnlyValue: primaryMobile,
          ),
          _MultiCategorySelector(
            label: 'Skills',
            buttonLabel: 'Select skills',
            sheetTitle: 'Select your skills',
            options: skillSelectorOptions,
            selectedIds: {
              ..._skillCategoryIds,
              if (_otherSkillSelected) _otherSkillId,
            },
            disabled: disabled,
            onChanged: (values) {
              final selected = Set<String>.from(values);
              final otherSelected = selected.remove(_otherSkillId);
              setState(() {
                _skillCategoryIds
                  ..clear()
                  ..addAll(selected);
                _otherSkillSelected = otherSelected;
                if (!otherSelected) {
                  _customSkill.clear();
                }
              });
              _scheduleAutoSave();
            },
          ),
          if (_otherSkillSelected)
            _field(
              label: 'Other skill',
              placeholder: 'Enter the name of your skill',
              controller: _customSkill,
              disabled: disabled,
              errorText: state.fieldErrors['custom_skills'],
            ),
          _field(
            label: 'Skill detail',
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
            placeholder: 'Describe your work',
            controller: _bio,
            disabled: disabled,
            maxLines: 3,
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
      ],
    );
  }

  bool _isOtherBusinessCategory(List<CategoryOption> options) {
    return options.any(
      (option) =>
          option.id == _businessCategoryId &&
          option.name.toLowerCase().startsWith('other'),
    );
  }

  Widget _addressStep({required bool disabled, required ProfileState state}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Select your location and confirm it with the PIN code.'),
        const SizedBox(height: 20),
        _locationAutocomplete(
          key: const ValueKey('profile-state'),
          label: 'State / Union Territory',
          placeholder: _loadingStates ? 'Loading states...' : 'Type to search',
          controller: _state,
          options: _states,
          selected: _selectedState,
          disabled: disabled || _loadingStates,
          errorText: state.fieldErrors['state_id'],
          onChanged: (value) {
            if (_selectedState?.name != value) {
              setState(() {
                _selectedState = null;
                _selectedDistrict = null;
                _districts = const [];
                _city.clear();
                _addressValidation = null;
              });
            }
            _scheduleAutoSave();
          },
          onSelected: (option) {
            setState(() {
              _selectedState = option;
              _state.text = option.name;
              _selectedDistrict = null;
              _city.clear();
              _districts = const [];
              _addressValidation = null;
            });
            _scheduleAutoSave();
            unawaited(_loadDistricts(option.id));
          },
        ),
        _locationAutocomplete(
          key: ValueKey('profile-district-${_selectedState?.id}'),
          label: 'City / District',
          placeholder: _selectedState == null
              ? 'Select state first'
              : _loadingDistricts
              ? 'Loading cities...'
              : 'Type to search',
          controller: _city,
          options: _districts,
          selected: _selectedDistrict,
          disabled: disabled || _selectedState == null || _loadingDistricts,
          errorText: state.fieldErrors['district_id'],
          onChanged: (value) {
            if (_selectedDistrict?.name != value) {
              setState(() {
                _selectedDistrict = null;
                _addressValidation = null;
              });
            }
            _scheduleAutoSave();
          },
          onSelected: (option) {
            setState(() {
              _selectedDistrict = option;
              _city.text = option.name;
              _addressValidation = null;
            });
            _scheduleAutoSave();
            _schedulePincodeValidation();
          },
        ),
        _field(
          label: 'House / shop / building / street',
          placeholder: 'Shop 108, Millennium Textile Market',
          controller: _addressLine1,
          disabled: disabled,
          maxLines: 2,
          errorText: state.fieldErrors['address_line1'],
        ),
        _field(
          label: 'Area / locality',
          placeholder: 'Ring Road, Varachha, Katargam',
          controller: _locality,
          disabled: disabled,
          errorText: state.fieldErrors['locality'],
          onChanged: (_) {
            _scheduleAutoSave();
            _schedulePincodeValidation();
          },
        ),
        _field(
          label: 'PIN code',
          placeholder: 'Enter 6 digit PIN code',
          controller: _pincode,
          disabled: disabled,
          keyboardType: TextInputType.number,
          errorText: state.fieldErrors['pincode'],
          maxLength: 6,
          onChanged: (_) {
            setState(() => _addressValidation = null);
            _scheduleAutoSave();
            _schedulePincodeValidation();
          },
        ),
        if (_validatingAddress)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Checking PIN code...'),
              ],
            ),
          ),
        if (_addressValidation case final validation?)
          _addressValidationPanel(validation),
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
    int? maxLength,
    ValueChanged<String>? onChanged,
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
              maxLength: maxLength,
              keyboardType: keyboardType,
              onChanged: onChanged ?? (_) => _scheduleAutoSave(),
              decoration: InputDecoration(
                hintText: placeholder,
                errorText: errorText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _locationAutocomplete({
    required Key key,
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required List<LocationOption> options,
    required LocationOption? selected,
    required bool disabled,
    required ValueChanged<String> onChanged,
    required ValueChanged<LocationOption> onSelected,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Autocomplete<LocationOption>(
            key: key,
            initialValue: TextEditingValue(
              text: selected?.name ?? controller.text,
            ),
            displayStringForOption: (option) => option.name,
            optionsBuilder: (text) {
              final query = text.text.trim().toLowerCase();
              if (query.isEmpty) {
                return options;
              }
              return options.where(
                (option) => option.name.toLowerCase().startsWith(query),
              );
            },
            onSelected: onSelected,
            fieldViewBuilder:
                (context, textController, focusNode, submitSelection) {
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    enabled: !disabled,
                    onChanged: (value) {
                      controller.text = value;
                      onChanged(value);
                    },
                    decoration: InputDecoration(
                      hintText: placeholder,
                      errorText: errorText,
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                  );
                },
            optionsViewBuilder: (context, select, matching) {
              final values = matching.toList(growable: false);
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(6),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 260,
                      maxWidth: 420,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: values.length,
                      itemBuilder: (context, index) {
                        final option = values[index];
                        return ListTile(
                          title: Text(option.name),
                          onTap: () => select(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _addressValidationPanel(AddressValidationResult validation) {
    final color = switch (validation.status) {
      'valid' => connectTeal,
      'warning' => connectAmber,
      _ => Theme.of(context).colorScheme.error,
    };
    final icon = switch (validation.status) {
      'valid' => Icons.verified_outlined,
      'warning' => Icons.info_outline,
      _ => Icons.error_outline,
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 10),
              Expanded(child: Text(validation.message)),
            ],
          ),
          if (validation.suggestedAreas.isNotEmpty &&
              validation.areaMatches == false) ...[
            const SizedBox(height: 12),
            const Text(
              'Postal areas for this PIN',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: validation.suggestedAreas
                  .take(6)
                  .map((area) {
                    return ActionChip(
                      label: Text(area),
                      onPressed: () {
                        _locality.text = area;
                        _scheduleAutoSave();
                        _schedulePincodeValidation();
                      },
                    );
                  })
                  .toList(growable: false),
            ),
          ],
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

  Future<void> _loadStates() async {
    if (_loadingStates || _states.isNotEmpty) {
      return;
    }
    setState(() => _loadingStates = true);
    try {
      final options = await ref.read(connectApiProvider).locationStates();
      if (!mounted) {
        return;
      }
      setState(() {
        _states = options;
        _loadingStates = false;
        final selectedId = _selectedState?.id;
        if (selectedId != null) {
          _selectedState = options
              .where((option) => option.id == selectedId)
              .firstOrNull;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingStates = false);
      }
    }
  }

  Future<void> _loadDistricts(int stateId) async {
    setState(() => _loadingDistricts = true);
    try {
      final options = await ref
          .read(connectApiProvider)
          .locationDistricts(stateId: stateId);
      if (!mounted || _selectedState?.id != stateId) {
        return;
      }
      setState(() {
        _districts = options;
        _loadingDistricts = false;
        final selectedId = _selectedDistrict?.id;
        if (selectedId != null) {
          _selectedDistrict = options
              .where((option) => option.id == selectedId)
              .firstOrNull;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingDistricts = false);
      }
    }
  }

  void _schedulePincodeValidation() {
    _pincodeValidationTimer?.cancel();
    if (_pincode.text.trim().length != 6 ||
        _selectedState == null ||
        _selectedDistrict == null) {
      return;
    }
    _pincodeValidationTimer = Timer(
      const Duration(milliseconds: 450),
      () => unawaited(_validateAddress()),
    );
  }

  Future<bool> _validateAddress() async {
    final state = _selectedState;
    final district = _selectedDistrict;
    final pincode = _pincode.text.trim();
    if (state == null || district == null || pincode.length != 6) {
      return false;
    }
    setState(() {
      _validatingAddress = true;
      _addressValidation = null;
    });
    try {
      final result = await ref
          .read(connectApiProvider)
          .validateAddress(
            stateId: state.id,
            districtId: district.id,
            pincode: pincode,
            area: _value(_locality),
          );
      if (!mounted || _pincode.text.trim() != pincode) {
        return false;
      }
      setState(() {
        _addressValidation = result;
        _validatingAddress = false;
      });
      return result.isAccepted;
    } catch (_) {
      if (mounted) {
        setState(() => _validatingAddress = false);
      }
      return false;
    }
  }

  void _initialize(OwnerProfileResult ownerProfile) {
    final details = ownerProfile.roleSpecific;
    _ownerName.text = details['owner_name']?.toString() ?? '';
    _alternateContact.text =
        details['alternate_contact_number']?.toString() ?? '';
    _addressLine1.text =
        details['address_line1']?.toString() ??
        details['full_address']?.toString() ??
        '';
    _locality.text = details['locality']?.toString() ?? '';
    _city.text = details['city']?.toString() ?? '';
    _state.text = details['state']?.toString() ?? '';
    _pincode.text = details['pincode']?.toString() ?? '';
    final stateId = details['state_id'] as int?;
    final districtId = details['district_id'] as int?;
    if (stateId != null) {
      _selectedState = LocationOption(id: stateId, name: _state.text);
    }
    if (districtId != null) {
      _selectedDistrict = LocationOption(id: districtId, name: _city.text);
    }
    _businessName.text = details['business_name']?.toString() ?? '';
    _businessCategoryId = details['business_category_id']?.toString();
    _customBusinessCategory.text =
        details['custom_business_category']?.toString() ?? '';
    _manufactureSell.text =
        details['manufacture_sell_details']?.toString() ?? '';
    _workshopName.text = details['workshop_name']?.toString() ?? '';
    _hasWorkshop = details['has_workshop'] as bool? ?? true;
    _workSummary.text = details['work_summary']?.toString() ?? '';
    final skillIds = details['skill_category_ids'] as List<dynamic>? ?? [];
    _skillCategoryIds.addAll(skillIds.map((value) => value.toString()));
    final legacySkillId = details['primary_skill_category_id']?.toString();
    if (_skillCategoryIds.isEmpty && legacySkillId != null) {
      _skillCategoryIds.add(legacySkillId);
    }
    final customSkills = details['custom_skills'] as List<dynamic>? ?? [];
    if (customSkills.isNotEmpty) {
      _customSkill.text = customSkills.first.toString();
      _otherSkillSelected = true;
    }
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
        _otherProductSelected = true;
      }
    }
    _initialized = true;
    _lastPersistedPayload = _payload();
    if (stateId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_loadDistricts(stateId));
        _schedulePincodeValidation();
      });
    }
  }

  Map<String, dynamic> _payload() {
    final profile = ref.read(profileControllerProvider).profile!;
    final role = profile.profile.role;
    final fields = <String, dynamic>{
      'owner_name': _value(_ownerName),
      'alternate_contact_number': _value(_alternateContact),
      'address_line1': _value(_addressLine1),
      'locality': _value(_locality),
      'city': _selectedDistrict?.name,
      'state': _selectedState?.name,
      'state_id': _selectedState?.id,
      'district_id': _selectedDistrict?.id,
      'pincode': _pincode.text.trim().length == 6 ? _value(_pincode) : null,
    };
    if (role == 'business') {
      fields.addAll({
        'business_name': _value(_businessName),
        'business_category_id': _businessCategoryId,
        'custom_business_category': _value(_customBusinessCategory),
        'manufacture_sell_details': _value(_manufactureSell),
        'product_type_ids': _productTypeIds.toList(growable: false),
        'custom_product_types':
            !_otherProductSelected || _value(_customProduct) == null
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
        'skill_category_ids': _skillCategoryIds.toList(growable: false),
        'custom_skills': !_otherSkillSelected || _value(_customSkill) == null
            ? <String>[]
            : [_value(_customSkill)],
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
    if (_savedOnce) {
      setState(() => _savedOnce = false);
    }
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) {
        return;
      }
      unawaited(_saveDraft());
    });
  }

  Future<bool> _saveDraft() async {
    _autoSaveTimer?.cancel();
    final activeSave = _saveFuture;
    if (activeSave != null) {
      final saved = await activeSave;
      return saved ? _saveDraft() : false;
    }
    final payload = _payload();
    final changes = <String, dynamic>{};
    for (final entry in payload.entries) {
      if (!_sameFieldValue(_lastPersistedPayload[entry.key], entry.value)) {
        changes[entry.key] = entry.value;
      }
    }
    if (changes.isEmpty) {
      return true;
    }
    final save = ref.read(profileControllerProvider.notifier).save(changes);
    _saveFuture = save;
    try {
      final saved = await save;
      if (saved) {
        _lastPersistedPayload = {..._lastPersistedPayload, ...changes};
      }
      if (mounted && saved) {
        setState(() => _savedOnce = true);
      }
      return saved;
    } finally {
      _saveFuture = null;
    }
  }

  Future<void> _next() async {
    if (_step == 2) {
      final role = ref.read(profileControllerProvider).profile?.profile.role;
      if (role != 'skilled_worker' && _mediaSummary?.meetsMinimum != true) {
        return;
      }
    }
    setState(() => _isSubmitting = true);
    try {
      if (await _saveDraft() && mounted) {
        setState(() => _step += 1);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _saveAndExit() async {
    setState(() => _isSubmitting = true);
    try {
      if (await _saveDraft() && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _complete() async {
    setState(() => _isSubmitting = true);
    try {
      if (!await _saveDraft()) {
        return;
      }
      final complete = await ref
          .read(profileControllerProvider.notifier)
          .complete();
      if (complete && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _sameFieldValue(Object? left, Object? right) {
    if (left is List<Object?> && right is List<Object?>) {
      return listEquals(left, right);
    }
    return left == right;
  }
}

class _MultiCategorySelector extends StatelessWidget {
  const _MultiCategorySelector({
    required this.label,
    required this.buttonLabel,
    required this.sheetTitle,
    required this.options,
    required this.selectedIds,
    required this.disabled,
    required this.onChanged,
  });

  final String label;
  final String buttonLabel;
  final String sheetTitle;
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          OutlinedButton.icon(
            onPressed: disabled
                ? null
                : () async {
                    final result = await showModalBottomSheet<Set<String>>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => _MultiCategorySheet(
                        title: sheetTitle,
                        options: options,
                        selectedIds: selectedIds,
                      ),
                    );
                    if (result != null) {
                      onChanged(result);
                    }
                  },
            icon: const Icon(Icons.checklist_outlined),
            label: Text(buttonLabel),
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

class _MultiCategorySheet extends StatefulWidget {
  const _MultiCategorySheet({
    required this.title,
    required this.options,
    required this.selectedIds,
  });

  final String title;
  final List<CategoryOption> options;
  final Set<String> selectedIds;

  @override
  State<_MultiCategorySheet> createState() => _MultiCategorySheetState();
}

class _MultiCategorySheetState extends State<_MultiCategorySheet> {
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
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
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
