import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SpaceTimePoint {
  LatLng? coordinate;
  DateTime? timeStamp;
  
  static SpaceTimePoint fromMap(Map<String, dynamic> map) {
    SpaceTimePoint spaceTimePoint = SpaceTimePoint();
    GeoPoint geoPoint = map["coordinate"];
    spaceTimePoint.coordinate = LatLng(geoPoint.latitude, geoPoint.longitude);
    Timestamp timestamp = map["timestamp"];
    spaceTimePoint.timeStamp = DateTime.fromMillisecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
    return spaceTimePoint;
  }

  @override
  String toString() {
    return "SpaceTimeStamp(coordinate:$coordinate, timestamp: $timeStamp)";
  }
}