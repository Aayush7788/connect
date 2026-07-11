//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_job.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExportJob {
  /// Returns a new [ExportJob] instance.
  ExportJob({

    required  this.id,

    required  this.status,

     this.downloadUrl,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ExportJobStatusEnum status;



  @JsonKey(
    
    name: r'download_url',
    required: false,
    includeIfNull: false,
  )


  final String? downloadUrl;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExportJob &&
      other.id == id &&
      other.status == status &&
      other.downloadUrl == downloadUrl;

    @override
    int get hashCode =>
        id.hashCode +
        status.hashCode +
        downloadUrl.hashCode;

  factory ExportJob.fromJson(Map<String, dynamic> json) => _$ExportJobFromJson(json);

  Map<String, dynamic> toJson() => _$ExportJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ExportJobStatusEnum {
@JsonValue(r'queued')
queued(r'queued'),
@JsonValue(r'processing')
processing(r'processing'),
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'failed')
failed(r'failed');

const ExportJobStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


