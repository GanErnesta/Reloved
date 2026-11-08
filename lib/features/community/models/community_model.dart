class CommunityModel {
  final String id;
  final String name;
  final String memberCountText;
  final int memberCount;
  final String description;
  final String thumbnailAsset;
  final String backgroundAsset;
  final String bannerAsset;
  final bool isJoined;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.memberCountText,
    this.memberCount = 0,
    required this.description,
    required this.thumbnailAsset,
    required this.backgroundAsset,
    required this.bannerAsset,
    this.isJoined = false,
  });

  static String formatMemberCount(int count) {
    if (count >= 1000) {
      final rb = count ~/ 1000;
      return '${rb}rb Anggota';
    }
    return '$count Anggota';
  }

  factory CommunityModel.fromMap(
      Map<String, dynamic> map, {
        bool isJoined = false,
      }) {
    final int count = (map['member_count'] as num?)?.toInt() ?? 0;
    return CommunityModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      memberCount: count,
      memberCountText: formatMemberCount(count),
      description: map['description']?.toString() ?? '',
      thumbnailAsset: (map['thumbnail_url']?.toString().isNotEmpty ?? false)
          ? map['thumbnail_url'].toString()
          : 'assets/images/community_thumb_malang.png',
      backgroundAsset: (map['background_url']?.toString().isNotEmpty ?? false)
          ? map['background_url'].toString()
          : 'assets/images/community_bg_malang.png',
      bannerAsset: (map['banner_url']?.toString().isNotEmpty ?? false)
          ? map['banner_url'].toString()
          : 'assets/images/community_banner_malang.png',
      isJoined: isJoined,
    );
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? memberCountText,
    int? memberCount,
    String? description,
    String? thumbnailAsset,
    String? backgroundAsset,
    String? bannerAsset,
    bool? isJoined,
  }) {
    final nextCount = memberCount ?? this.memberCount;
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      memberCount: nextCount,
      memberCountText: memberCountText ?? formatMemberCount(nextCount),
      description: description ?? this.description,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
      backgroundAsset: backgroundAsset ?? this.backgroundAsset,
      bannerAsset: bannerAsset ?? this.bannerAsset,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}