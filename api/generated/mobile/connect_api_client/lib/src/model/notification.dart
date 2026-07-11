//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Notification {
  /// Returns a new [Notification] instance.
  Notification({

    required  this.id,

    required  this.title,

    required  this.message,

    required  this.createdAt,

     this.readAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'read_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? readAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Notification &&
      other.id == id &&
      other.title == title &&
      other.message == message &&
      other.createdAt == createdAt &&
      other.readAt == readAt;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        message.hashCode +
        createdAt.hashCode +
        readAt.hashCode;

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

