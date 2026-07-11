//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum SearchTarget {
      @JsonValue(r'business')
      business(r'business'),
      @JsonValue(r'job_worker')
      jobWorker(r'job_worker'),
      @JsonValue(r'skilled_worker')
      skilledWorker(r'skilled_worker');

  const SearchTarget(this.value);

  final String value;

  @override
  String toString() => value;
}
