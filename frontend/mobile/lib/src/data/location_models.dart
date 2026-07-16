class LocationOption {
  const LocationOption({required this.id, required this.name});

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(id: json['id'] as int, name: json['name'] as String);
  }

  final int id;
  final String name;
}

class AddressValidationResult {
  const AddressValidationResult({
    required this.status,
    required this.pincode,
    required this.stateMatches,
    required this.districtMatches,
    required this.message,
    this.areaMatches,
    this.canonicalState,
    this.canonicalDistrict,
    this.suggestedAreas = const [],
  });

  factory AddressValidationResult.fromJson(Map<String, dynamic> json) {
    return AddressValidationResult(
      status: json['status'] as String,
      pincode: json['pincode'] as String,
      stateMatches: json['state_matches'] as bool,
      districtMatches: json['district_matches'] as bool,
      areaMatches: json['area_matches'] as bool?,
      canonicalState: json['canonical_state'] == null
          ? null
          : LocationOption.fromJson(
              json['canonical_state'] as Map<String, dynamic>,
            ),
      canonicalDistrict: json['canonical_district'] == null
          ? null
          : LocationOption.fromJson(
              json['canonical_district'] as Map<String, dynamic>,
            ),
      suggestedAreas: (json['suggested_areas'] as List<dynamic>? ?? const [])
          .cast<String>(),
      message: json['message'] as String,
    );
  }

  final String status;
  final String pincode;
  final bool stateMatches;
  final bool districtMatches;
  final bool? areaMatches;
  final LocationOption? canonicalState;
  final LocationOption? canonicalDistrict;
  final List<String> suggestedAreas;
  final String message;

  bool get isAccepted => status == 'valid' || status == 'warning';
}
