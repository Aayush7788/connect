import 'package:connect_app/src/data/connect_api.dart';
import 'package:connect_app/src/data/engagement_models.dart';
import 'package:connect_app/src/features/engagement/engagement_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final engagementControllerProvider =
    NotifierProvider<EngagementController, EngagementState>(
      EngagementController.new,
    );

class EngagementState {
  const EngagementState({
    this.savedItems = const [],
    this.notifications = const [],
    this.pushNotificationsEnabled = true,
    this.isLoadingSaved = false,
    this.isLoadingNotifications = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<SavedItemResult> savedItems;
  final List<NotificationResult> notifications;
  final bool pushNotificationsEnabled;
  final bool isLoadingSaved;
  final bool isLoadingNotifications;
  final bool isSaving;
  final String? errorMessage;

  EngagementState copyWith({
    List<SavedItemResult>? savedItems,
    List<NotificationResult>? notifications,
    bool? pushNotificationsEnabled,
    bool? isLoadingSaved,
    bool? isLoadingNotifications,
    bool? isSaving,
    Object? errorMessage = _unchanged,
  }) {
    return EngagementState(
      savedItems: savedItems ?? this.savedItems,
      notifications: notifications ?? this.notifications,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      isLoadingSaved: isLoadingSaved ?? this.isLoadingSaved,
      isLoadingNotifications:
          isLoadingNotifications ?? this.isLoadingNotifications,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _unchanged = Object();

class EngagementController extends Notifier<EngagementState> {
  @override
  EngagementState build() => const EngagementState();

  Future<void> loadSaved() async {
    if (state.isLoadingSaved) {
      return;
    }
    state = state.copyWith(isLoadingSaved: true, errorMessage: null);
    try {
      final items = await ref.read(engagementRepositoryProvider).savedItems();
      state = state.copyWith(
        savedItems: items,
        isLoadingSaved: false,
        errorMessage: null,
      );
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isLoadingSaved: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingSaved: false,
        errorMessage: "Can't access internet",
      );
    }
  }

  SavedItemResult? savedProfile(String profileId) {
    for (final item in state.savedItems) {
      if (item.targetType == 'profile' && item.targetId == profileId) {
        return item;
      }
    }
    return null;
  }

  Future<bool> toggleProfile(String profileId) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final existing = savedProfile(profileId);
      if (existing == null) {
        final saved = await ref
            .read(engagementRepositoryProvider)
            .saveProfile(profileId);
        state = state.copyWith(
          savedItems: [...state.savedItems, saved],
          isSaving: false,
        );
      } else {
        await ref.read(engagementRepositoryProvider).removeSaved(existing.id);
        state = state.copyWith(
          savedItems: state.savedItems
              .where((item) => item.id != existing.id)
              .toList(growable: false),
          isSaving: false,
        );
      }
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Can't access internet",
      );
      return false;
    }
  }

  Future<bool> removeSaved(String savedItemId) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await ref.read(engagementRepositoryProvider).removeSaved(savedItemId);
      state = state.copyWith(
        savedItems: state.savedItems
            .where((item) => item.id != savedItemId)
            .toList(growable: false),
        isSaving: false,
      );
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Can't access internet",
      );
      return false;
    }
  }

  Future<void> loadNotifications() async {
    if (state.isLoadingNotifications) {
      return;
    }
    state = state.copyWith(isLoadingNotifications: true, errorMessage: null);
    try {
      final notifications = await ref
          .read(engagementRepositoryProvider)
          .notifications();
      state = state.copyWith(
        notifications: notifications,
        isLoadingNotifications: false,
      );
    } on ApiFailure catch (error) {
      state = state.copyWith(
        isLoadingNotifications: false,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingNotifications: false,
        errorMessage: "Can't access internet",
      );
    }
  }

  Future<void> markRead(String notificationId) async {
    final existing = state.notifications.where(
      (item) => item.id == notificationId,
    );
    if (existing.isEmpty || existing.first.readAt != null) {
      return;
    }
    try {
      final updated = await ref
          .read(engagementRepositoryProvider)
          .markRead(notificationId);
      state = state.copyWith(
        notifications: [
          for (final item in state.notifications)
            if (item.id == notificationId) updated else item,
        ],
      );
    } catch (_) {}
  }

  Future<bool> setPushNotifications(bool enabled) async {
    if (state.isSaving) {
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final settings = await ref
          .read(engagementRepositoryProvider)
          .updateSettings(pushNotificationsEnabled: enabled);
      state = state.copyWith(
        pushNotificationsEnabled: settings.pushNotificationsEnabled,
        isSaving: false,
      );
      return true;
    } on ApiFailure catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Can't access internet",
      );
      return false;
    }
  }

  Future<void> loadSettings() async {
    try {
      final settings = await ref.read(engagementRepositoryProvider).settings();
      state = state.copyWith(
        pushNotificationsEnabled: settings.pushNotificationsEnabled,
      );
    } catch (_) {}
  }
}
