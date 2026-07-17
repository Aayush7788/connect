//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:connect_api_client/src/model/profile_summary.dart';
import 'package:connect_api_client/src/model/account_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_profile.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminProfile {
  /// Returns a new [AdminProfile] instance.
  AdminProfile({
    required this.profile,

    this.ownerUserId,

    this.ownerMobile,

    required this.isAdminSeeded,

    this.claimStatus,

    this.accountStatus,

    this.fullAddress,
  });

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final ProfileSummary profile;

  @JsonKey(name: r'owner_user_id', required: false, includeIfNull: false)
  final String? ownerUserId;

  @JsonKey(name: r'owner_mobile', required: false, includeIfNull: false)
  final String? ownerMobile;

  @JsonKey(name: r'is_admin_seeded', required: true, includeIfNull: false)
  final bool isAdminSeeded;

  @JsonKey(name: r'claim_status', required: false, includeIfNull: false)
  final AdminProfileClaimStatusEnum? claimStatus;

  @JsonKey(name: r'account_status', required: false, includeIfNull: false)
  final AccountStatus? accountStatus;

  @JsonKey(name: r'full_address', required: false, includeIfNull: false)
  final String? fullAddress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminProfile &&
          other.profile == profile &&
          other.ownerUserId == ownerUserId &&
          other.ownerMobile == ownerMobile &&
          other.isAdminSeeded == isAdminSeeded &&
          other.claimStatus == claimStatus &&
          other.accountStatus == accountStatus &&
          other.fullAddress == fullAddress;

  @override
  int get hashCode =>
      profile.hashCode +
      ownerUserId.hashCode +
      ownerMobile.hashCode +
      isAdminSeeded.hashCode +
      claimStatus.hashCode +
      accountStatus.hashCode +
      fullAddress.hashCode;

  factory AdminProfile.fromJson(Map<String, dynamic> json) =>
      _$AdminProfileFromJson(json);

  Map<String, dynamic> toJson() => _$AdminProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AdminProfileClaimStatusEnum {
  @JsonValue(r'unclaimed')
  unclaimed(r'unclaimed'),
  @JsonValue(r'claimed')
  claimed(r'claimed'),
  @JsonValue(r'not_claimable')
  notClaimable(r'not_claimable');

  const AdminProfileClaimStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
