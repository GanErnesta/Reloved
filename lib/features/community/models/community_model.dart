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

  static List<CommunityModel> dummyCommunities = [
    const CommunityModel(
      id: 'com_1',
      name: 'Mahasiswa Malang',
      memberCountText: '100rb Anggota',
      description:
      'Komunitas ini bukan sekadar komunitas biasa, Melainkan sebuah wadah untuk mahasiswa, khususnya mahasiswa Malang, yang ingin menjual/membeli barang yang sudah tidak dipakai dan masih dalam keadaan bagus...',
      thumbnailAsset: 'assets/images/community_thumb.png',
      backgroundAsset: 'assets/images/community_card_bg.png',
      bannerAsset: 'assets/images/community_banner_malang.png',
    ),
    const CommunityModel(
      id: 'com_2',
      name: 'Komunitas Mager UB',
      memberCountText: '50rb Anggota',
      description:
      'Wadah berbagi informasi barang pre-loved, titip beli, dan kebutuhan kos sekitar area Universitas Brawijaya.',
      thumbnailAsset: 'assets/images/community_thumb.png',
      backgroundAsset: 'assets/images/community_card_bg.png',
      bannerAsset: 'assets/images/community_banner_malang.png',
    ),
    const CommunityModel(
      id: 'com_3',
      name: 'Mahasiswa UIN',
      memberCountText: '50rb Anggota',
      description:
      'Komunitas jual beli dan tukar tambah barang bekas layak pakai khusus mahasiswa UIN Malang.',
      thumbnailAsset: 'assets/images/community_thumb.png',
      backgroundAsset: 'assets/images/community_card_bg.png',
      bannerAsset: 'assets/images/community_banner_malang.png',
    ),
  ];
}