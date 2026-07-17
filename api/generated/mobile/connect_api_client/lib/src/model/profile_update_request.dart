//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProfileUpdateRequest {
  /// Returns a new [ProfileUpdateRequest] instance.
  ProfileUpdateRequest({

     this.ownerName,

     this.alternateContactNumber,

     this.fullAddress,

     this.addressLine1,

     this.addressLine2,

     this.locality,

     this.city,

     this.state,

     this.pincode,

     this.stateId,

     this.districtId,

     this.businessName,

     this.businessCategoryId,

     this.customBusinessCategory,

     this.manufactureSellDetails,

     this.productNotes,

     this.productTypeIds,

     this.customProductTypes,

     this.workshopName,

     this.hasWorkshop,

     this.workSummary,

     this.profileExperienceYears,

     this.primarySkillCategoryId,

     this.skillMastery,

     this.experienceYears,

     this.bio,
  });

  @JsonKey(

    name: r'owner_name',
    required: false,
    includeIfNull: false,
  )


  final String? ownerName;



  @JsonKey(
    
    name: r'alternate_contact_number',
    required: false,
    includeIfNull: false,
  )


  final String? alternateContactNumber;



  @JsonKey(
    
    name: r'full_address',
    required: false,
    includeIfNull: false,
  )


  final String? fullAddress;



  @JsonKey(
    
    name: r'address_line1',
    required: false,
    includeIfNull: false,
  )


  final String? addressLine1;



  @JsonKey(
    
    name: r'address_line2',
    required: false,
    includeIfNull: false,
  )


  final String? addressLine2;



  @JsonKey(
    
    name: r'locality',
    required: false,
    includeIfNull: false,
  )


  final String? locality;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false,
  )


  final String? city;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final String? state;



  @JsonKey(
    
    name: r'pincode',
    required: false,
    includeIfNull: false,
  )


  final String? pincode;



          // minimum: 1
  @JsonKey(
    
    name: r'state_id',
    required: false,
    includeIfNull: false,
  )


  final int? stateId;



          // minimum: 1
  @JsonKey(
    
    name: r'district_id',
    required: false,
    includeIfNull: false,
  )


  final int? districtId;



  @JsonKey(
    
    name: r'business_name',
    required: false,
    includeIfNull: false,
  )


  final String? businessName;



  @JsonKey(
    
    name: r'business_category_id',
    required: false,
    includeIfNull: false,
  )


  final String? businessCategoryId;



  @JsonKey(
    
    name: r'custom_business_category',
    required: false,
    includeIfNull: false,
  )


  final String? customBusinessCategory;



  @JsonKey(

    name: r'manufacture_sell_details',
    required: false,
    includeIfNull: false,
  )


  final String? manufactureSellDetails;



  @JsonKey(
    
    name: r'product_notes',
    required: false,
    includeIfNull: false,
  )


  final String? productNotes;



  @JsonKey(
    
    name: r'product_type_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? productTypeIds;



  @JsonKey(
    
    name: r'custom_product_types',
    required: false,
    includeIfNull: false,
  )


  final List<String>? customProductTypes;



  @JsonKey(
    
    name: r'workshop_name',
    required: false,
    includeIfNull: false,
  )


  final String? workshopName;



  @JsonKey(
    
    name: r'has_workshop',
    required: false,
    includeIfNull: false,
  )


  final bool? hasWorkshop;



  @JsonKey(
    
    name: r'work_summary',
    required: false,
    includeIfNull: false,
  )


  final String? workSummary;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'profile_experience_years',
    required: false,
    includeIfNull: false,
  )


  final int? profileExperienceYears;



  @JsonKey(
    
    name: r'primary_skill_category_id',
    required: false,
    includeIfNull: false,
  )


  final String? primarySkillCategoryId;



  @JsonKey(
    
    name: r'skill_mastery',
    required: false,
    includeIfNull: false,
  )


  final String? skillMastery;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'experience_years',
    required: false,
    includeIfNull: false,
  )


  final int? experienceYears;



  @JsonKey(
    
    name: r'bio',
    required: false,
    includeIfNull: false,
  )


  final String? bio;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProfileUpdateRequest &&
      other.ownerName == ownerName &&
      other.alternateContactNumber == alternateContactNumber &&
      other.fullAddress == fullAddress &&
      other.addressLine1 == addressLine1 &&
      other.addressLine2 == addressLine2 &&
      other.locality == locality &&
      other.city == city &&
      other.state == state &&
      other.pincode == pincode &&
      other.stateId == stateId &&
      other.districtId == districtId &&
      other.businessName == businessName &&
      other.businessCategoryId == businessCategoryId &&
      other.customBusinessCategory == customBusinessCategory &&
      other.manufactureSellDetails == manufactureSellDetails &&
      other.productNotes == productNotes &&
      other.productTypeIds == productTypeIds &&
      other.customProductTypes == customProductTypes &&
      other.workshopName == workshopName &&
      other.hasWorkshop == hasWorkshop &&
      other.workSummary == workSummary &&
      other.profileExperienceYears == profileExperienceYears &&
      other.primarySkillCategoryId == primarySkillCategoryId &&
      other.skillMastery == skillMastery &&
      other.experienceYears == experienceYears &&
      other.bio == bio;

    @override
    int get hashCode =>
        ownerName.hashCode +
        alternateContactNumber.hashCode +
        fullAddress.hashCode +
        addressLine1.hashCode +
        addressLine2.hashCode +
        locality.hashCode +
        city.hashCode +
        state.hashCode +
        pincode.hashCode +
        stateId.hashCode +
        districtId.hashCode +
        businessName.hashCode +
        businessCategoryId.hashCode +
        customBusinessCategory.hashCode +
        manufactureSellDetails.hashCode +
        productNotes.hashCode +
        productTypeIds.hashCode +
        customProductTypes.hashCode +
        workshopName.hashCode +
        hasWorkshop.hashCode +
        workSummary.hashCode +
        profileExperienceYears.hashCode +
        primarySkillCategoryId.hashCode +
        skillMastery.hashCode +
        experienceYears.hashCode +
        bio.hashCode;

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) => _$ProfileUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
