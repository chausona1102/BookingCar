import 'package:pocketbase/pocketbase.dart';

class LocationModel {
  final String? id;
  final String placeName;
  final String latitude;
  final String longitude;
  LocationModel({
    this.id,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      placeName: json['placeName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'placename': placeName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationModel.fromRecord(RecordModel r) {
    return LocationModel(
      placeName: (r.data['placename']).toString(),
      latitude: (r.data['latitude']).toString(),
      longitude: (r.data['longitude']).toString(),
    );
  }
}
