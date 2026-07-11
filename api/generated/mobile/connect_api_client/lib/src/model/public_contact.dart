//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_contact.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicContact {
  /// Returns a new [PublicContact] instance.
  PublicContact({

     this.mobile,

     this.whatsappNumber,
  });

  @JsonKey(
    
    name: r'mobile',
    required: false,
    includeIfNull: false,
  )


  final String? mobile;



  @JsonKey(
    
    name: r'whatsapp_number',
    required: false,
    includeIfNull: false,
  )


  final String? whatsappNumber;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicContact &&
      other.mobile == mobile &&
      other.whatsappNumber == whatsappNumber;

    @override
    int get hashCode =>
        mobile.hashCode +
        whatsappNumber.hashCode;

  factory PublicContact.fromJson(Map<String, dynamic> json) => _$PublicContactFromJson(json);

  Map<String, dynamic> toJson() => _$PublicContactToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

