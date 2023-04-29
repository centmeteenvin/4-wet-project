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
    Stream<List<Device>> snapshotMap = snapshot.map((event) => event.docs.map(
          (e) {
            Map<String, dynamic> map = e.data() as Map<String, dynamic>;
            map["deviceId"] = e.id;
            return Device.fromMap(map);
          },
        ).toList());
    return snapshotMap;
  }

  Stream<List<SpaceTimePoint>> getLocationsStream(String deviceId) {
    var ref = _db.collection('Devices');
    Stream<Device> deviceStream = ref.doc(deviceId).snapshots().map((event) {
      Map<String, dynamic> map =
          event.data() ?? {"deviceName": "DeviceNotFound", "locations": []};
      map["deviceId"] = event.id;
      return Device.fromMap(map);
    });
    return deviceStream.map((event) => event.locations);
  }
  
  Stream<Device?> getDeviceStream(String deviceId) {
    var ref = _db.collection('Devices');
    return ref.doc(deviceId).snapshots().map((snapshot) {
      Map<String, dynamic>? map = snapshot.data();
      if (map == null) return null;
      map["deviceId"] = deviceId;
      return Device.fromMap(map);
    });
     
  }

  void update(Device device) {
    var ref = _db.collection('Devices');
    ref.doc(device.deviceId).set(device.toMap());
  }
}
