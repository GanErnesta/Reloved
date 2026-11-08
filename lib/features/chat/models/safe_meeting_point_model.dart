
class SafeMeetingPointModel {
  final String id;
  final String name;
  final String fullAddress;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const SafeMeetingPointModel({
    required this.id,
    required this.name,
    required this.fullAddress,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory SafeMeetingPointModel.fromJson(Map<String, dynamic> json) {
    return SafeMeetingPointModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_address': fullAddress,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
