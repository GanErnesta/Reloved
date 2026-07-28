class Campus {
  final int id;
  final String name;
  final String shortName;
  final String domain;
  final String? logoUrl;
  final String? city;
  final String? province;

  const Campus({
    required this.id,
    required this.name,
    required this.shortName,
    required this.domain,
    this.logoUrl,
    this.city,
    this.province,
  });

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'] ?? '',
      domain: json['domain'],
      logoUrl: json['logo_url'],
      city: json['city'],
      province: json['province'],
    );
  }
}