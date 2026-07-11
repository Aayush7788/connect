//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/admin_verification_case.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_verification_cases_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminVerificationCasesResponse {
  /// Returns a new [AdminVerificationCasesResponse] instance.
  AdminVerificationCasesResponse({

    required  this.items,

     this.nextCursor,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<AdminVerificationCase> items;



  @JsonKey(
    
    name: r'next_cursor',
    required: false,
    includeIfNull: false,
  )


  final String? nextCursor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminVerificationCasesResponse &&
      other.items == items &&
      other.nextCursor == nextCursor;

    @override
    int get hashCode =>
        items.hashCode +
        nextCursor.hashCode;

  factory AdminVerificationCasesResponse.fromJson(Map<String, dynamic> json) => _$AdminVerificationCasesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminVerificationCasesResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

