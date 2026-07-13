import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/engagement_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  return EngagementRepository(ref.watch(connectApiProvider));
});

class EngagementRepository {
  const EngagementRepository(this._api);

  final ConnectApi _api;

  Future<List<SavedItemResult>> savedItems() => _api.savedItems();

  Future<SavedItemResult> saveProfile(String profileId) {
    return _api.saveItem(targetType: 'profile', targetId: profileId);
  }

  Future<void> removeSaved(String savedItemId) {
    return _api.removeSavedItem(savedItemId);
  }

  Future<List<NotificationResult>> notifications() => _api.notifications();

  Future<NotificationResult> markRead(String notificationId) {
    return _api.markNotificationRead(notificationId);
  }

  Future<UserSettingsResult> updateSettings({
    bool? pushNotificationsEnabled,
    bool? hiddenFromSearch,
  }) {
    return _api.updateSettings(
      pushNotificationsEnabled: pushNotificationsEnabled,
      hiddenFromSearch: hiddenFromSearch,
    );
  }

  Future<UserSettingsResult> settings() => _api.userSettings();

  Future<void> reportProfile(String profileId, String reason) {
    return _api.createReport(
      targetType: 'profile',
      targetId: profileId,
      reason: reason,
    );
  }

  Future<void> logContact({
    required String profileId,
    required String actionType,
    String? sourceType,
    String? sourceId,
  }) {
    return _api.logContactAction(
      profileId: profileId,
      actionType: actionType,
      sourceType: sourceType,
      sourceId: sourceId,
    );
  }

  Future<ShareLinkResult> shareProfile(String profileId) {
    return _api.createShareLink(
      targetType: 'profile',
      targetId: profileId,
      channel: 'native_other',
    );
  }
}
