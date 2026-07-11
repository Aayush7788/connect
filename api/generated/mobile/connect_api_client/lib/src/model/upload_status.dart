//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum UploadStatus {
      @JsonValue(r'pending_upload')
      pendingUpload(r'pending_upload'),
      @JsonValue(r'uploaded')
      uploaded(r'uploaded'),
      @JsonValue(r'processing')
      processing(r'processing'),
      @JsonValue(r'ready')
      ready(r'ready'),
      @JsonValue(r'failed')
      failed(r'failed'),
      @JsonValue(r'deleted')
      deleted(r'deleted');

  const UploadStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
