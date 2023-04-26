import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'dart:ffi';

import 'package:smollar_dts/utils/models/device.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smollar_dts/utils/models/space_time_point.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Device>> getAllDevices() async {
    var ref = _db.collection('Devices');
    var snapshot = await ref.get();
    // log(snapshot.docs.toString());
    var data = snapshot.docs.map((s) {
      Map<String, dynamic> mappedData = s.data();
      mappedData["deviceId"] = s.id;
      return Device.fromMap(mappedData);
    });
    return data.toList();
  }

  Stream<List<Device>> getAllDevicesStream() {
    var ref = _db.collection('Devices');
    Stream<QuerySnapshot> snapshot = ref.snapshots();
    Stream<List<Device>> snapshotMap = snapshot.map((event) => event.docs.map((e) {
      Map<String, dynamic> map = e.data() as Map<String, dynamic>;
      map["deviceId"] = e.id;
      return Device.fromMap(map);
    },).toList());
    return snapshotMap;
  }

  Stream<List<SpaceTimePoint>> getLocationsStream(String deviceId) {
    var ref = _db.collection('Devices');
    Stream<Device> deviceStream = ref
        .doc(deviceId)
        .snapshots()
        .map((event) {
          Map<String, dynamic> map = event.data() ?? {"deviceName": "DeviceNotFound", "locations":  []};
          map["deviceId"] = event.id;
          return Device.fromMap(map);
        });
    return deviceStream.map((event) => event.locations);
  }

  void callBack(String deviceId) {
    var ref = _db.collection('Devices');
    ref.doc(deviceId).update({"callBack":true});
  }

  void setFence(String deviceId, Fence fence) {
    var ref = _db.collection('Devices');
    ref.doc(deviceId).update({"fence": fence.toMap()});
  }
}