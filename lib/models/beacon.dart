import 'dart:convert';

class Beacon {
  final String name;
  final String uuid;
  final int major;
  final int minor;

  final int rssi;
  final double distance;
  final String proximity;

  Beacon({
    required this.minor,
    required this.name,
    required this.uuid,
    required this.major,
    required this.rssi,
    required this.distance,
    required this.proximity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uuid': uuid,
      'major': major,
      'minor': minor,
      'rssi': rssi,
      'distance': distance,
      'proximity': proximity,
    };
  }

  factory Beacon.fromMap(Map<String, dynamic> map) {
    return Beacon(
      name: map['name'] ?? '',
      uuid: map['uuid'] ?? '',
      major: int.tryParse(map['major']) ?? 0,
      minor: int.tryParse(map['minor']) ?? 0,
      rssi: int.tryParse(map['rssi'] ?? '0') ?? 0,
      distance: double.tryParse(map['distance']) ?? 0.0,
      proximity: map['proximity'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Beacon.fromJson(String source) => Beacon.fromMap(json.decode(source));
}
