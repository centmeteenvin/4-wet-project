import 'package:flutter/material.dart';
import 'package:smollar_dts/utils/services/firestore.dart';
import 'fence.dart';
import 'space_time_point.dart';

@immutable
class Device {
  final String deviceId;
  final String deviceName;
  final List<SpaceTimePoint> locations;
  final bool comeBack;
  final Fence fence;

  const Device({
    required this.deviceId,
    this.deviceName = "",
    this.locations = const [],
    this.comeBack = false,
    required this.fence,
  });

  @override
  String toString() {
    return "Device(deviceId: $deviceId, deviceName: $deviceName, locations: $locations)";
  }

  Device copyWith(
      {String? deviceId,
      String? deviceName,
      List<SpaceTimePoint>? locations,
      bool? comeBack,
      Fence? fence}) {
    if (locations != null) {
      locations = List<SpaceTimePoint>.unmodifiable(locations);
    }
    return Device(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      locations: locations ?? this.locations,
      fence: fence ?? this.fence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "deviceName": deviceName,
      "locations": locations.map((e) => e.toMap()).toList(),
      "callBack": comeBack,
      "fence": fence.toMap(),
    };
  }

  static Device fromMap(Map<String, dynamic> map) {
    List locations = map["locations"] as List;

    return Device(
      deviceId: map["deviceId"],
      deviceName: map["deviceName"],
      locations: locations.map((e) => SpaceTimePoint.fromMap(e)).toList(),
      fence: Fence.fromMap(map["fence"]),
    );
  }

  void update() {
    FirestoreService().update(this);
  }
}
