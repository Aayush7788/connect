import 'package:connect_api_client/src/model/address_validation_request.dart';
import 'package:connect_api_client/src/model/address_validation_response.dart';
import 'package:connect_api_client/src/model/admin_analytics_summary.dart';
import 'package:connect_api_client/src/model/admin_analytics_summary_top_search_terms_inner.dart';
import 'package:connect_api_client/src/model/admin_approve_verification_case_request.dart';
import 'package:connect_api_client/src/model/admin_profile.dart';
import 'package:connect_api_client/src/model/admin_profiles_response.dart';
import 'package:connect_api_client/src/model/admin_report.dart';
import 'package:connect_api_client/src/model/admin_reports_response.dart';
import 'package:connect_api_client/src/model/admin_seed_profile_request.dart';
import 'package:connect_api_client/src/model/admin_user.dart';
import 'package:connect_api_client/src/model/admin_verification_case.dart';
import 'package:connect_api_client/src/model/admin_verification_case_checks_inner.dart';
import 'package:connect_api_client/src/model/admin_verification_case_private_document_access_inner.dart';
import 'package:connect_api_client/src/model/admin_verification_cases_response.dart';
import 'package:connect_api_client/src/model/auth_session_response.dart';
import 'package:connect_api_client/src/model/basic_account_request.dart';
import 'package:connect_api_client/src/model/category.dart';
import 'package:connect_api_client/src/model/category_list_response.dart';
import 'package:connect_api_client/src/model/confirm_role_request.dart';
import 'package:connect_api_client/src/model/contact_action_request.dart';
import 'package:connect_api_client/src/model/create_export_request.dart';
import 'package:connect_api_client/src/model/create_report_request.dart';
import 'package:connect_api_client/src/model/create_share_link_request.dart';
import 'package:connect_api_client/src/model/device_info.dart';
import 'package:connect_api_client/src/model/error_response.dart';
import 'package:connect_api_client/src/model/error_response_error.dart';
import 'package:connect_api_client/src/model/export_job.dart';
import 'package:connect_api_client/src/model/list_my_work_cards200_response.dart';
import 'package:connect_api_client/src/model/list_my_work_needed_posts200_response.dart';
import 'package:connect_api_client/src/model/location_option.dart';
import 'package:connect_api_client/src/model/location_option_list.dart';
import 'package:connect_api_client/src/model/me_response.dart';
import 'package:connect_api_client/src/model/media_asset.dart';
import 'package:connect_api_client/src/model/notification.dart';
import 'package:connect_api_client/src/model/notifications_response.dart';
import 'package:connect_api_client/src/model/otp_request.dart';
import 'package:connect_api_client/src/model/otp_request_response.dart';
import 'package:connect_api_client/src/model/otp_verify_request.dart';
import 'package:connect_api_client/src/model/owner_profile_response.dart';
import 'package:connect_api_client/src/model/profile_summary.dart';
import 'package:connect_api_client/src/model/profile_update_request.dart';
import 'package:connect_api_client/src/model/public_address.dart';
import 'package:connect_api_client/src/model/public_contact.dart';
import 'package:connect_api_client/src/model/public_profile_detail.dart';
import 'package:connect_api_client/src/model/register_device_token_request.dart';
import 'package:connect_api_client/src/model/report.dart';
import 'package:connect_api_client/src/model/save_item_request.dart';
import 'package:connect_api_client/src/model/saved_item.dart';
import 'package:connect_api_client/src/model/saved_items_response.dart';
import 'package:connect_api_client/src/model/search_response.dart';
import 'package:connect_api_client/src/model/search_result.dart';
import 'package:connect_api_client/src/model/share_link_response.dart';
import 'package:connect_api_client/src/model/update_settings_request.dart';
import 'package:connect_api_client/src/model/upload_details.dart';
import 'package:connect_api_client/src/model/upload_intent_request.dart';
import 'package:connect_api_client/src/model/upload_intent_response.dart';
import 'package:connect_api_client/src/model/user.dart';
import 'package:connect_api_client/src/model/user_settings.dart';
import 'package:connect_api_client/src/model/verification_submit_request.dart';
import 'package:connect_api_client/src/model/verification_summary.dart';
import 'package:connect_api_client/src/model/verification_summary_checks_inner.dart';
import 'package:connect_api_client/src/model/verification_summary_safe_documents_inner.dart';
import 'package:connect_api_client/src/model/work_card.dart';
import 'package:connect_api_client/src/model/work_card_upsert_request.dart';
import 'package:connect_api_client/src/model/work_needed_post.dart';
import 'package:connect_api_client/src/model/work_needed_post_upsert_request.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AccountStatus':
    case 'AddressValidationRequest':
      return AddressValidationRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AddressValidationResponse':
      return AddressValidationResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminAnalyticsSummary':
      return AdminAnalyticsSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminAnalyticsSummaryTopSearchTermsInner':
      return AdminAnalyticsSummaryTopSearchTermsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AdminApproveVerificationCaseRequest':
      return AdminApproveVerificationCaseRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AdminProfile':
      return AdminProfile.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AdminProfilesResponse':
      return AdminProfilesResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminReport':
      return AdminReport.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AdminReportsResponse':
      return AdminReportsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminSeedProfileRequest':
      return AdminSeedProfileRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminUser':
      return AdminUser.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AdminVerificationCase':
      return AdminVerificationCase.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminVerificationCaseChecksInner':
      return AdminVerificationCaseChecksInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AdminVerificationCasePrivateDocumentAccessInner':
      return AdminVerificationCasePrivateDocumentAccessInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AdminVerificationCasesResponse':
      return AdminVerificationCasesResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AuthSessionResponse':
      return AuthSessionResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'BasicAccountRequest':
      return BasicAccountRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Category':
      return Category.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'CategoryListResponse':
      return CategoryListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CategoryType':
    case 'ConfirmRoleRequest':
      return ConfirmRoleRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ContactActionRequest':
      return ContactActionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateExportRequest':
      return CreateExportRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateReportRequest':
      return CreateReportRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateShareLinkRequest':
      return CreateShareLinkRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DeviceInfo':
      return DeviceInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ErrorResponse':
      return ErrorResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ErrorResponseError':
      return ErrorResponseError.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExportJob':
      return ExportJob.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ListMyWorkCards200Response':
      return ListMyWorkCards200Response.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ListMyWorkNeededPosts200Response':
      return ListMyWorkNeededPosts200Response.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'LocationOption':
      return LocationOption.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LocationOptionList':
      return LocationOptionList.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MeResponse':
      return MeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MediaAsset':
      return MediaAsset.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MediaKind':
    case 'MediaVisibility':
    case 'Notification':
      return Notification.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'NotificationsResponse':
      return NotificationsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OtpRequest':
      return OtpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'OtpRequestResponse':
      return OtpRequestResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OtpVerifyRequest':
      return OtpVerifyRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OwnerProfileResponse':
      return OwnerProfileResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProfileSummary':
      return ProfileSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProfileUpdateRequest':
      return ProfileUpdateRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProfileVisibilityStatus':
    case 'PublicAddress':
      return PublicAddress.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PublicContact':
      return PublicContact.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PublicProfileDetail':
      return PublicProfileDetail.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterDeviceTokenRequest':
      return RegisterDeviceTokenRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Report':
      return Report.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ReportReason':
    case 'ReportStatus':
    case 'SaveItemRequest':
      return SaveItemRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SavedItem':
      return SavedItem.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SavedItemsResponse':
      return SavedItemsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SavedTargetType':
    case 'SearchResponse':
      return SearchResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SearchResult':
      return SearchResult.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SearchTarget':
    case 'ShareLinkResponse':
      return ShareLinkResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UpdateSettingsRequest':
      return UpdateSettingsRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UploadDetails':
      return UploadDetails.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UploadIntentRequest':
      return UploadIntentRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UploadIntentResponse':
      return UploadIntentResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UploadStatus':
    case 'User':
      return User.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UserRole':
    case 'UserSettings':
      return UserSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'VerificationCaseStatus':
    case 'VerificationStatus':
    case 'VerificationSubmitRequest':
      return VerificationSubmitRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerificationSummary':
      return VerificationSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerificationSummaryChecksInner':
      return VerificationSummaryChecksInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'VerificationSummarySafeDocumentsInner':
      return VerificationSummarySafeDocumentsInner.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'WorkCard':
      return WorkCard.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WorkCardStatus':
    case 'WorkCardUpsertRequest':
      return WorkCardUpsertRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkNeededPost':
      return WorkNeededPost.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkNeededPostStatus':
    case 'WorkNeededPostUpsertRequest':
      return WorkNeededPostUpsertRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
