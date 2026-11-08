import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_comment_model.dart';
import '../models/community_model.dart';
import '../models/community_post_model.dart';

class CommunityRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Mengambil info nama & foto_profil user yang sedang login
  Future<Map<String, String>> getCurrentUserProfileSummary() async {
    final uid = currentUserId;
    if (uid == null) {
      return {
        'nama': 'Mahasiswa UB',
        'foto_profil': 'assets/images/avatar_falisha.png',
      };
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select('nama, foto_profil')
          .eq('id', uid)
          .maybeSingle();

      return {
        'nama': (data?['nama']?.toString().isNotEmpty ?? false)
            ? data!['nama'].toString()
            : 'Mahasiswa UB',
        'foto_profil': (data?['foto_profil']?.toString().isNotEmpty ?? false)
            ? data!['foto_profil'].toString()
            : 'assets/images/avatar_falisha.png',
      };
    } catch (_) {
      return {
        'nama': 'Mahasiswa UB',
        'foto_profil': 'assets/images/avatar_falisha.png',
      };
    }
  }

  /// 1. Mengambil daftar semua komunitas beserta status isJoined user
  Future<List<CommunityModel>> getCommunities({String? searchQuery}) async {
    var query = _supabase.from('communities').select();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }

    final List<dynamic> rows = await query.order('created_at');
    final uid = currentUserId;

    Set<String> joinedCommunityIds = {};
    if (uid != null) {
      final memberRows = await _supabase
          .from('community_members')
          .select('community_id')
          .eq('user_id', uid);

      joinedCommunityIds = memberRows
          .map((e) => e['community_id'].toString())
          .toSet();
    }

    return rows.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = map['id'].toString();
      return CommunityModel.fromMap(
        map,
        isJoined: joinedCommunityIds.contains(id),
      );
    }).toList();
  }

  /// 2. Join / Leave Komunitas
  Future<bool> toggleJoinCommunity(String communityId, bool currentlyJoined) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('Silakan login terlebih dahulu untuk bergabung.');
    }

    if (currentlyJoined) {
      await _supabase
          .from('community_members')
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', uid);
      return false;
    } else {
      await _supabase.from('community_members').upsert({
        'community_id': communityId,
        'user_id': uid,
      });
      return true;
    }
  }

  /// 3. Mengambil daftar postingan (Bisa difilter per Komunitas, Jelajahi, atau per User untuk Profile)
  Future<List<CommunityPostModel>> getPosts({
    String? communityId,
    String? authorId,
    bool sortByPopular = false,
  }) async {
    var filterQuery = _supabase.from('community_posts').select('''
      id,
      community_id,
      author_id,
      content,
      attached_product_id,
      like_count,
      comment_count,
      created_at,
      profiles!community_posts_author_id_fkey (
        id,
        nama,
        foto_profil
      ),
      products!community_posts_attached_product_id_fkey (
        id,
        name,
        price,
        image_url
      )
    ''');

    if (communityId != null && communityId.isNotEmpty) {
      filterQuery = filterQuery.eq('community_id', communityId);
    }

    if (authorId != null && authorId.isNotEmpty) {
      filterQuery = filterQuery.eq('author_id', authorId);
    }

    final List<dynamic> rows = sortByPopular
        ? await filterQuery
        .order('like_count', ascending: false)
        .order('created_at', ascending: false)
        : await filterQuery.order('created_at', ascending: false);

    final uid = currentUserId;
    Set<String> likedPostIds = {};

    if (uid != null && rows.isNotEmpty) {
      final postIds = rows.map((r) => r['id'].toString()).toList();
      final likeRows = await _supabase
          .from('community_post_likes')
          .select('post_id')
          .eq('user_id', uid)
          .inFilter('post_id', postIds);

      likedPostIds = likeRows.map((e) => e['post_id'].toString()).toSet();
    }

    return rows.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final postId = map['id'].toString();
      return CommunityPostModel.fromMap(
        map,
        isLiked: likedPostIds.contains(postId),
      );
    }).toList();
  }

  /// 4. Khusus untuk Halaman Profile: Mengambil semua postingan yang pernah dipost oleh User
  Future<List<CommunityPostModel>> getUserPosts({String? userId}) async {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) return [];
    return getPosts(authorId: targetUserId, sortByPopular: false);
  }

  /// 5. Membuat Postingan Baru di Komunitas
  Future<CommunityPostModel> createPost({
    required String communityId,
    required String content,
    String? attachedProductId,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('Silakan login terlebih dahulu untuk membuat postingan.');
    }

    final inserted = await _supabase
        .from('community_posts')
        .insert({
      'community_id': communityId,
      'author_id': uid,
      'content': content.trim(),
      if (attachedProductId != null && attachedProductId.isNotEmpty)
        'attached_product_id': attachedProductId,
    })
        .select('''
          id,
          community_id,
          author_id,
          content,
          attached_product_id,
          like_count,
          comment_count,
          created_at,
          profiles!community_posts_author_id_fkey (
            id,
            nama,
            foto_profil
          ),
          products!community_posts_attached_product_id_fkey (
            id,
            name,
            price,
            image_url
          )
        ''')
        .single();

    return CommunityPostModel.fromMap(
      Map<String, dynamic>.from(inserted),
      isLiked: false,
    );
  }

  /// 6. Like / Unlike Postingan
  Future<bool> togglePostLike(String postId, bool currentlyLiked) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    if (currentlyLiked) {
      await _supabase
          .from('community_post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', uid);
      return false;
    } else {
      await _supabase.from('community_post_likes').upsert({
        'post_id': postId,
        'user_id': uid,
      });
      return true;
    }
  }

  /// 7. Mengambil Produk dari Katalog User Sendiri (Tabel products)
  Future<List<UserProductModel>> getMyCatalogProducts() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final List<dynamic> rows = await _supabase
        .from('products')
        .select('id, name, price, condition, image_url, image_urls, status, stock')
        .eq('seller_id', uid)
        .order('created_at', ascending: false);

    return rows
        .map((r) => UserProductModel.fromMap(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  /// 8. Mengambil Komentar pada Postingan
  Future<List<CommunityCommentModel>> getComments(String postId) async {
    final List<dynamic> rows = await _supabase
        .from('community_comments')
        .select('''
          id,
          post_id,
          author_id,
          content,
          like_count,
          created_at,
          profiles!community_comments_author_id_fkey (
            id,
            nama,
            foto_profil
          )
        ''')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    final uid = currentUserId;
    Set<String> likedCommentIds = {};

    if (uid != null && rows.isNotEmpty) {
      final commentIds = rows.map((r) => r['id'].toString()).toList();
      final likeRows = await _supabase
          .from('community_comment_likes')
          .select('comment_id')
          .eq('user_id', uid)
          .inFilter('comment_id', commentIds);

      likedCommentIds =
          likeRows.map((e) => e['comment_id'].toString()).toSet();
    }

    return rows.map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final cid = map['id'].toString();
      return CommunityCommentModel.fromMap(
        map,
        isLiked: likedCommentIds.contains(cid),
      );
    }).toList();
  }

  /// 9. Menambahkan Komentar Baru
  Future<CommunityCommentModel> addComment({
    required String postId,
    required String content,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('Silakan login terlebih dahulu untuk berkomentar.');
    }

    final inserted = await _supabase
        .from('community_comments')
        .insert({
      'post_id': postId,
      'author_id': uid,
      'content': content.trim(),
    })
        .select('''
          id,
          post_id,
          author_id,
          content,
          like_count,
          created_at,
          profiles!community_comments_author_id_fkey (
            id,
            nama,
            foto_profil
          )
        ''')
        .single();

    return CommunityCommentModel.fromMap(
      Map<String, dynamic>.from(inserted),
      isLiked: false,
    );
  }

  /// 10. Like / Unlike Komentar
  Future<bool> toggleCommentLike(String commentId, bool currentlyLiked) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    if (currentlyLiked) {
      await _supabase
          .from('community_comment_likes')
          .delete()
          .eq('comment_id', commentId)
          .eq('user_id', uid);
      return false;
    } else {
      await _supabase.from('community_comment_likes').upsert({
        'comment_id': commentId,
        'user_id': uid,
      });
      return true;
    }
  }
}