import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>> getAllDevices() async {
    var ref = _db.collection('Devices');
    var snapshot = await ref.get();
    // log(snapshot.docs.toString());
    var data = snapshot.docs.map((s) => s.data().toString());
    return data.toList();
  }
}