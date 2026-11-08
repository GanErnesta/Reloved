class CommunityCommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final int likeCount;
  final bool isLiked;

  const CommunityCommentModel({
    required this.id,
    this.postId = '',
    this.authorId = '',
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.likeCount,
    this.isLiked = false,
  });

  factory CommunityCommentModel.fromMap(
      Map<String, dynamic> map, {
        bool isLiked = false,
      }) {
    final profileMap = map['profiles'] as Map<String, dynamic>?;
    final String rawAvatar = profileMap?['foto_profil']?.toString() ?? '';

    return CommunityCommentModel(
      id: map['id']?.toString() ?? '',
      postId: map['post_id']?.toString() ?? '',
      authorId: map['author_id']?.toString() ?? '',
      authorName: (profileMap?['nama']?.toString().isNotEmpty ?? false)
          ? profileMap!['nama'].toString()
          : 'Mahasiswa UB',
      authorAvatar: rawAvatar.isNotEmpty
          ? rawAvatar
          : 'assets/images/avatar_falisha.png',
      content: map['content']?.toString() ?? '',
      likeCount: (map['like_count'] as num?)?.toInt() ?? 0,
      isLiked: isLiked,
    );
  }

  CommunityCommentModel copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    int? likeCount,
    bool? isLiked,
  }) {
    return CommunityCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}