import 'space_time_point.dart';

class Device {
  final String deviceId;
  String deviceName = "";
  List<SpaceTimePoint> locations = [];

  Device({required this.deviceId, this.deviceName = "", this.locations = const []});

  static Device fromMap(Map<String, dynamic> map) {
    List locations = map["locations"] as List; 
    return Device(
      deviceId: map["deviceId"],
      deviceName: map["deviceName"],
      locations: locations.map((e) => SpaceTimePoint.fromMap(e)).toList(),
    );
  }

  @override
  String toString() {
    return "Device(deviceId: $deviceId, deviceName: $deviceName, locations: $locations)";
  }
}