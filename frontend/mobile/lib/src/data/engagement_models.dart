import 'package:connect_app/src/data/discovery_models.dart';

class SavedItemResult {
  const SavedItemResult({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.profileRole,
    this.card,
  });

  factory SavedItemResult.fromJson(Map<String, dynamic> json) {
    return SavedItemResult(
      id: json['id'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      profileRole: json['profile_role'] as String,
      card: json['card'] == null
          ? null
          : MarketplaceSearchResult.fromJson(
              json['card'] as Map<String, dynamic>,
            ),
    );
  }

  final String id;
  final String targetType;
  final String targetId;
  final String profileRole;
  final MarketplaceSearchResult? card;
}

class NotificationResult {
  const NotificationResult({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationResult.fromJson(Map<String, dynamic> json) {
    return NotificationResult(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );
  }

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationResult copyWith({DateTime? readAt}) {
    return NotificationResult(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

class UserSettingsResult {
  const UserSettingsResult({
    required this.pushNotificationsEnabled,
    required this.hiddenFromSearch,
  });

  factory UserSettingsResult.fromJson(Map<String, dynamic> json) {
    return UserSettingsResult(
      pushNotificationsEnabled:
          json['push_notifications_enabled'] as bool? ?? true,
      hiddenFromSearch: json['hidden_from_search'] as bool? ?? false,
    );
  }

  final bool pushNotificationsEnabled;
  final bool hiddenFromSearch;
}

class ShareLinkResult {
  const ShareLinkResult({required this.url, required this.shareText});

  factory ShareLinkResult.fromJson(Map<String, dynamic> json) {
    return ShareLinkResult(
      url: json['url'] as String,
      shareText: json['share_text'] as String? ?? json['url'] as String,
    );
  }

  final String url;
  final String shareText;
}
