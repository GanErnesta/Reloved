class AttachedProductModel {
  final String id;
  final String title;
  final String price;

  const AttachedProductModel({
    required this.id,
    required this.title,
    required this.price,
  });
}

class CommunityPostModel {
  final String id;
  final String authorName;
  final String authorAvatar;
  final bool isVerified;
  final String timeAgo;
  final String content;
  final AttachedProductModel? attachedProduct;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const CommunityPostModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    this.isVerified = true,
    required this.timeAgo,
    required this.content,
    this.attachedProduct,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
  });

  CommunityPostModel copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    bool? isVerified,
    String? timeAgo,
    String? content,
    AttachedProductModel? attachedProduct,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isVerified: isVerified ?? this.isVerified,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      attachedProduct: attachedProduct ?? this.attachedProduct,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  static List<CommunityPostModel> dummyPosts = [
    const CommunityPostModel(
      id: 'post_1',
      authorName: 'Falisha Keyrani',
      authorAvatar: 'assets/images/avatar_falisha.png',
      isVerified: true,
      timeAgo: '2j yang lalu',
      content:
      'Jual buku Algoritma & Pemrograman edisi ke-3 kondisi bagus, hampir ga ada coretan. Masih relevan untuk matkul DDP! Cek katalog yuk🛒',
      attachedProduct: AttachedProductModel(
        id: 'prod_1',
        title: 'Buku Algoritma & Pemrograman Ed.3',
        price: 'Rp 85.000',
      ),
      likeCount: 24,
      commentCount: 8,
    ),
    const CommunityPostModel(
      id: 'post_2',
      authorName: 'Falisha Keyrani',
      authorAvatar: 'assets/images/avatar_falisha.png',
      isVerified: true,
      timeAgo: '2j yang lalu',
      content:
      'Lagi punya 5 buku tere liye nih, barangkali ada yang butuh mau?',
      attachedProduct: AttachedProductModel(
        id: 'prod_2',
        title: 'Buku Tere Liye',
        price: 'Rp 85.000',
      ),
      likeCount: 24,
      commentCount: 8,
    ),
  ];
}