//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/report_reason.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_report_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateReportRequest {
  /// Returns a new [CreateReportRequest] instance.
  CreateReportRequest({

    required  this.reportedEntityType,

    required  this.reportedEntityId,

    required  this.reason,
  });

  @JsonKey(
    
    name: r'reported_entity_type',
    required: true,
    includeIfNull: false,
  )


  final CreateReportRequestReportedEntityTypeEnum reportedEntityType;



  @JsonKey(
    
    name: r'reported_entity_id',
    required: true,
    includeIfNull: false,
  )


  final String reportedEntityId;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final ReportReason reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateReportRequest &&
      other.reportedEntityType == reportedEntityType &&
      other.reportedEntityId == reportedEntityId &&
      other.reason == reason;

    @override
    int get hashCode =>
        reportedEntityType.hashCode +
        reportedEntityId.hashCode +
        reason.hashCode;

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) => _$CreateReportRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReportRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateReportRequestReportedEntityTypeEnum {
@JsonValue(r'profile')
profile(r'profile'),
@JsonValue(r'work_card')
workCard(r'work_card'),
@JsonValue(r'work_needed_post')
workNeededPost(r'work_needed_post');

const CreateReportRequestReportedEntityTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


