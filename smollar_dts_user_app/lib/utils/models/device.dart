import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smollar_dts/utils/services/firestore.dart';
import 'space_time_point.dart';

class Device {
  final String deviceId;
  String deviceName = "";
  List<SpaceTimePoint> locations = [];
  bool comeBack = false;
  Fence fence;

  Device({required this.deviceId, this.deviceName = "", this.locations = const [], required this.fence } );


  static Device fromMap(Map<String, dynamic> map) {
    List locations = map["locations"] as List; 
    GeoPoint anchor = map["fence"]["anchor"] as GeoPoint;
    return Device(
      deviceId: map["deviceId"],
      deviceName: map["deviceName"],
      locations: locations.map((e) => SpaceTimePoint.fromMap(e)).toList(),
      fence: Fence(
        anchor: LatLng(anchor.latitude, anchor.longitude),
        distance: map["fence"]["distance"] as double,
        inUse: map["fence"]["inUse"] as bool,
      ),
    );
  }

  @override
  String toString() {
    return "Device(deviceId: $deviceId, deviceName: $deviceName, locations: $locations)";
  }

  void callBack() {
    comeBack = true;
    FirestoreService().callBack(deviceId);
  }
  void setFence(Fence fence) {
    this.fence = fence;
    FirestoreService().setFence(deviceId, fence);
  }
}

class DeviceNotifier extends StateNotifier<Device?> {
  DeviceNotifier(super.state);

  void set(Device device) {
    state = device;
  }
  
}

class DeviceListNotifier extends StreamNotifier<List<Device>> {
  @override
  Stream<List<Device>> build() {
    return FirestoreService().getAllDevicesStream();
  }
}

class Fence {
  LatLng anchor;
  double distance;
  bool inUse;

  Fence({required this.anchor, required this.distance, this.inUse = false});

  Map<String, dynamic> toMap() {
    return {
      "anchor": GeoPoint(anchor.latitude, anchor.longitude),
      "distance": distance,
      "inUse": inUse,
    };
  }
}