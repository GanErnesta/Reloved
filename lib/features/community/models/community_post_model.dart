class AttachedProductModel {
  final String id;
  final String title;
  final String price;
  final String? imageUrl;

  const AttachedProductModel({
    required this.id,
    required this.title,
    required this.price,
    this.imageUrl,
  });

  factory AttachedProductModel.fromMap(Map<String, dynamic> map) {
    final num rawPrice = (map['price'] as num?) ?? 0;
    return AttachedProductModel(
      id: map['id']?.toString() ?? '',
      title: map['name']?.toString() ?? '',
      price: UserProductModel.formatRupiah(rawPrice),
      imageUrl: map['image_url']?.toString(),
    );
  }
}

class UserProductModel {
  final String id;
  final String title;
  final String price;
  final String imageAsset;
  final String condition;
  final bool isSold;

  const UserProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageAsset,
    required this.condition,
    this.isSold = false,
  });

  static String formatRupiah(num number) {
    final intVal = number.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intVal.length; i++) {
      if (i > 0 && (intVal.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intVal[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  factory UserProductModel.fromMap(Map<String, dynamic> map) {
    final num rawPrice = (map['price'] as num?) ?? 0;
    final String status = (map['status']?.toString() ?? 'available').toLowerCase();
    final int stock = (map['stock'] as num?)?.toInt() ?? 1;

    String resolvedImage = map['image_url']?.toString() ?? '';
    if (resolvedImage.isEmpty && map['image_urls'] is List) {
      final list = map['image_urls'] as List;
      if (list.isNotEmpty) {
        resolvedImage = list.first.toString();
      }
    }

    return UserProductModel(
      id: map['id']?.toString() ?? '',
      title: map['name']?.toString() ?? '',
      price: formatRupiah(rawPrice),
      imageAsset: resolvedImage.isNotEmpty
          ? resolvedImage
          : 'assets/images/prod_buku_algo.png',
      condition: map['condition']?.toString() ?? 'Bekas Baik',
      isSold: status != 'available' || stock <= 0,
    );
  }
}

class CommunityPostModel {
  final String id;
  final String communityId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final bool isVerified;
  final String timeAgo;
  final DateTime createdAt;
  final String content;
  final AttachedProductModel? attachedProduct;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const CommunityPostModel({
    required this.id,
    this.communityId = '',
    this.authorId = '',
    required this.authorName,
    required this.authorAvatar,
    this.isVerified = true,
    required this.timeAgo,
    required this.createdAt,
    required this.content,
    this.attachedProduct,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
  });

  static String formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    if (diff.inDays < 7) return '${diff.inDays}h yang lalu';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  factory CommunityPostModel.fromMap(
      Map<String, dynamic> map, {
        bool isLiked = false,
      }) {
    final profileMap = map['profiles'] as Map<String, dynamic>?;
    final productMap = map['products'] as Map<String, dynamic>?;
    final created = map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString())?.toLocal() ??
        DateTime.now()
        : DateTime.now();

    final String rawAvatar = profileMap?['foto_profil']?.toString() ?? '';

    return CommunityPostModel(
      id: map['id']?.toString() ?? '',
      communityId: map['community_id']?.toString() ?? '',
      authorId: map['author_id']?.toString() ?? '',
      authorName: (profileMap?['nama']?.toString().isNotEmpty ?? false)
          ? profileMap!['nama'].toString()
          : 'Mahasiswa UB',
      authorAvatar: rawAvatar.isNotEmpty
          ? rawAvatar
          : 'assets/images/avatar_falisha.png',
      isVerified: true,
      timeAgo: formatTimeAgo(created),
      createdAt: created,
      content: map['content']?.toString() ?? '',
      attachedProduct: productMap != null
          ? AttachedProductModel.fromMap(productMap)
          : null,
      likeCount: (map['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (map['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: isLiked,
    );
  }

  CommunityPostModel copyWith({
    String? id,
    String? communityId,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    bool? isVerified,
    String? timeAgo,
    DateTime? createdAt,
    String? content,
    AttachedProductModel? attachedProduct,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isVerified: isVerified ?? this.isVerified,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      attachedProduct: attachedProduct ?? this.attachedProduct,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}