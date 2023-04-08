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
    Stream<Device> deviceStream = ref.doc(deviceId).snapshots().asyncMap((event) => Device.fromMap(event.data()!));
    return deviceStream.map((event) => event.locations,);
  }
}