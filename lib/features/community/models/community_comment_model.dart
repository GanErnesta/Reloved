class CommunityCommentModel {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final int likeCount;
  final bool isLiked;

  const CommunityCommentModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.likeCount,
    this.isLiked = false,
  });

  CommunityCommentModel copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? content,
    int? likeCount,
    bool? isLiked,
  }) {
    return CommunityCommentModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  static List<CommunityCommentModel> initialComments = [
    const CommunityCommentModel(
      id: 'c_1',
      authorName: 'Windah Basudara',
      authorAvatar: 'assets/images/avatar_windah.png',
      content:
      'Wih! kebetulan aku pengen banget buku itu... aku pasti akan menamatkan buku ini!',
      likeCount: 10,
      isLiked: false,
    ),
    const CommunityCommentModel(
      id: 'c_2',
      authorName: 'Timothy Ronald',
      authorAvatar: 'assets/images/avatar_timothy.png',
      content: 'Aduh harus beli secepatnya nih! sebelum habis.',
      likeCount: 11,
      isLiked: true,
    ),
  ];
}