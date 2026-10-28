class CommunityModel {
  final String id;
  final String name;
  final String memberCountText;
  final String description;
  final String thumbnailAsset;
  final String backgroundAsset;
  final String bannerAsset;
  final bool isJoined;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.memberCountText,
    required this.description,
    required this.thumbnailAsset,
    required this.backgroundAsset,
    required this.bannerAsset,
    this.isJoined = false,
  });

  CommunityModel copyWith({
    String? id,
    String? name,
    String? memberCountText,
    String? description,
    String? thumbnailAsset,
    String? backgroundAsset,
    String? bannerAsset,
    bool? isJoined,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      memberCountText: memberCountText ?? this.memberCountText,
      description: description ?? this.description,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
      backgroundAsset: backgroundAsset ?? this.backgroundAsset,
      bannerAsset: bannerAsset ?? this.bannerAsset,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  static List<CommunityModel> dummyCommunities = [
    const CommunityModel(
      id: 'com_1',
      name: 'Mahasiswa Malang',
      memberCountText: '100rb Anggota',
      description:
      'Komunitas ini bukan sekadar komunitas biasa, Melainkan sebuah wadah untuk mahasiswa, khususnya mahasiswa Malang, yang ingin menjual/membeli barang yang sudah tidak dipakai dan masih dalam keadaan bagus. Kamu juga bisa berdiskusi seputar kebutuhan kuliah, mencari referensi buku modul, hingga berbagi info perlengkapan kos dengan aman dan nyaman.',
      thumbnailAsset: 'assets/images/community_thumb.png',
      backgroundAsset: 'assets/images/community_card_bg.png',
      bannerAsset: 'assets/images/community_banner_malang.png',
    ),
    const CommunityModel(
      id: 'com_2',
      name: 'Komunitas Mager UB',
      memberCountText: '50rb Anggota',
      description:
      'Wadah berbagi informasi barang pre-loved, buku kuliah, jas lab, dan kebutuhan kos khusus mahasiswa di sekitar area Universitas Brawijaya. Transaksi lebih dekat dan aman melalui titik temu resmi di dalam kampus.',
      thumbnailAsset: 'assets/images/community_thumb_mager_ub.png',
      backgroundAsset: 'assets/images/community_bg_mager_ub.png',
      bannerAsset: 'assets/images/community_banner_mager_ub.png',
    ),
    const CommunityModel(
      id: 'com_3',
      name: 'Mahasiswa UIN',
      memberCountText: '50rb Anggota',
      description:
      'Komunitas jual beli, sewa barang harian, dan tukar tambah barang bekas layak pakai khusus mahasiswa UIN Malang. Temukan perlengkapan kuliah dan atribut organisasi dengan harga terjangkau.',
      thumbnailAsset: 'assets/images/community_thumb_uin.png',
      backgroundAsset: 'assets/images/community_bg_uin.png',
      bannerAsset: 'assets/images/community_banner_uin.png',
    ),
  ];
}