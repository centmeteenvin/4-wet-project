import 'package:smollar_dts/utils/models/device.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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
}