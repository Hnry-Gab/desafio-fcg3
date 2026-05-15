/// Banner model matching BannerResponse from the backend API.
///
/// Backend fields: id, image_url, is_enabled, display_order, created_at, updated_at.
class BannerModel {
  final String id;
  final String imageUrl;
  final bool isEnabled;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.isEnabled,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as String,
        imageUrl: json['image_url'] as String,
        isEnabled: (json['is_enabled'] as bool?) ?? true,
        displayOrder: (json['display_order'] as int?) ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  BannerModel copyWith({
    String? id,
    String? imageUrl,
    bool? isEnabled,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isEnabled: isEnabled ?? this.isEnabled,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
