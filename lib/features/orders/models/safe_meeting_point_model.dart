class SafeMeetingPointModel {
  final String id;
  final String name;
  final String fullAddress;
  final String imagePath;

  const SafeMeetingPointModel({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.imagePath,
  });

  static const List<SafeMeetingPointModel> campusPoints = [
    SafeMeetingPointModel(
      id: 'SMP-1',
      name: 'Perpustakaan Pusat Kampus',
      fullAddress:
      'Gedung Perpustakaan, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_perpustakaan.png',
    ),
    SafeMeetingPointModel(
      id: 'SMP-2',
      name: 'Lobby Utama Gedung F Filkom UB',
      fullAddress:
      'Lobby Utama Gedung F FILKOM UB, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_filkom.png',
    ),
    SafeMeetingPointModel(
      id: 'SMP-3',
      name: 'Gedung Student Center / Pusat Kegiatan Mahasiswa',
      fullAddress:
      'Gedung EM/PKM UB, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_student_center.png',
    ),
    SafeMeetingPointModel(
      id: 'SMP-4',
      name: 'Pos Penjagaan Satpam / Markas Keamanan Pusat Kampus',
      fullAddress:
      'Markas Komando Keamanan UB, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_pos_satpam.png',
    ),
    SafeMeetingPointModel(
      id: 'SMP-5',
      name: 'Gedung Samantha Krida (Sakri) UB',
      fullAddress:
      'Gedung Samantha Krida, Jl. MT. Haryono, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_sakri.png',
    ),
    SafeMeetingPointModel(
      id: 'SMP-6',
      name: 'Gazebo Raden Wijaya UB',
      fullAddress:
      'Area Gazebo Raden Wijaya, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_gazebo.png',
    ),
    SafeMeetingPointModel(
      id: 'SMP-7',
      name: 'Pelataran Masjid Raden Patah UB',
      fullAddress:
      'Masjid Raden Patah UB, Jl. Kampus Brawijaya, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_mrp.png',
    ),
    SafeMeetingPointModel(
      id: 'SMP-8',
      name: 'Pos Keamanan Gerbang Veteran UB',
      fullAddress:
      'Gerbang Veteran UB, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      imagePath: 'assets/images/smp_gerbang_veteran.png',
    ),
  ];
}