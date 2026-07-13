class MediaAssetResult {
  const MediaAssetResult({
    required this.id,
    required this.mediaKind,
    required this.visibility,
    required this.uploadStatus,
    required this.sortOrder,
    this.url,
    this.thumbnailUrl,
    this.documentType,
    this.safeDisplayName,
  });

  factory MediaAssetResult.fromJson(Map<String, dynamic> json) {
    return MediaAssetResult(
      id: json['id'] as String,
      mediaKind: json['media_kind'] as String,
      visibility: json['visibility'] as String,
      uploadStatus: json['upload_status'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      documentType: json['document_type'] as String?,
      safeDisplayName: json['safe_display_name'] as String?,
    );
  }

  final String id;
  final String mediaKind;
  final String visibility;
  final String uploadStatus;
  final int sortOrder;
  final String? url;
  final String? thumbnailUrl;
  final String? documentType;
  final String? safeDisplayName;
}
