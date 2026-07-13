import 'package:connect_app/src/data/media_models.dart';

class WorkNeededPostResult {
  const WorkNeededPostResult({
    required this.id,
    required this.profileId,
    required this.status,
    required this.title,
    required this.productTypeIds,
    required this.customProductTexts,
    required this.productTypes,
    required this.photoCount,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.categoryName,
    this.customCategoryText,
    this.workNameId,
    this.workName,
    this.customWorkName,
    this.description,
    this.lastActivityAt,
    this.closedAt,
  });

  factory WorkNeededPostResult.fromJson(Map<String, dynamic> json) {
    return WorkNeededPostResult(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      status: json['status'] as String,
      title: json['title'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      customCategoryText: json['custom_category_text'] as String?,
      workNameId: json['work_name_id'] as String?,
      workName: json['work_name'] as String?,
      customWorkName: json['custom_work_name'] as String?,
      productTypeIds: (json['product_type_ids'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(growable: false),
      customProductTexts: (json['custom_product_texts'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(growable: false),
      productTypes: (json['product_types'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(growable: false),
      description: json['description'] as String?,
      photoCount: json['photo_count'] as int? ?? 0,
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map(
            (value) => MediaAssetResult.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
      lastActivityAt: _dateTime(json['last_activity_at']),
      closedAt: _dateTime(json['closed_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final String id;
  final String profileId;
  final String status;
  final String title;
  final String? categoryId;
  final String? categoryName;
  final String? customCategoryText;
  final String? workNameId;
  final String? workName;
  final String? customWorkName;
  final List<String> productTypeIds;
  final List<String> customProductTexts;
  final List<String> productTypes;
  final String? description;
  final int photoCount;
  final List<MediaAssetResult> photos;
  final DateTime? lastActivityAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayCategory =>
      categoryName ?? customCategoryText ?? 'Add category';

  String get displayWorkName =>
      workName ?? customWorkName ?? (title.isEmpty ? 'Untitled post' : title);

  static DateTime? _dateTime(dynamic value) {
    return value is String ? DateTime.tryParse(value) : null;
  }
}

class WorkNeededPostUpsert {
  const WorkNeededPostUpsert({
    this.categoryId,
    this.customCategoryText,
    this.workNameId,
    this.customWorkName,
    this.productTypeIds,
    this.customProductTexts,
    this.description,
  });

  final String? categoryId;
  final String? customCategoryText;
  final String? workNameId;
  final String? customWorkName;
  final List<String>? productTypeIds;
  final List<String>? customProductTexts;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      if (customCategoryText != null)
        'custom_category_text': customCategoryText,
      if (workNameId != null) 'work_name_id': workNameId,
      if (customWorkName != null) 'custom_work_name': customWorkName,
      if (productTypeIds != null) 'product_type_ids': productTypeIds,
      if (customProductTexts != null)
        'custom_product_texts': customProductTexts,
      if (description != null) 'description': description,
    };
  }
}
