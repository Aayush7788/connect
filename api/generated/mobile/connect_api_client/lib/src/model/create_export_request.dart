//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_export_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateExportRequest {
  /// Returns a new [CreateExportRequest] instance.
  CreateExportRequest({

    required  this.dataset,

     this.filters,
  });

  @JsonKey(
    
    name: r'dataset',
    required: true,
    includeIfNull: false,
  )


  final CreateExportRequestDatasetEnum dataset;



  @JsonKey(
    
    name: r'filters',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? filters;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateExportRequest &&
      other.dataset == dataset &&
      other.filters == filters;

    @override
    int get hashCode =>
        dataset.hashCode +
        filters.hashCode;

  factory CreateExportRequest.fromJson(Map<String, dynamic> json) => _$CreateExportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateExportRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateExportRequestDatasetEnum {
@JsonValue(r'profiles')
profiles(r'profiles'),
@JsonValue(r'verification_cases')
verificationCases(r'verification_cases'),
@JsonValue(r'reports')
reports(r'reports'),
@JsonValue(r'search_summary')
searchSummary(r'search_summary'),
@JsonValue(r'contact_summary')
contactSummary(r'contact_summary');

const CreateExportRequestDatasetEnum(this.value);

final String value;

@override
String toString() => value;
}


