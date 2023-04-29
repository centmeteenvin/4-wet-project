import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
class SpaceTimePoint {
  final LatLng coordinate;
  final DateTime timeStamp;

  const SpaceTimePoint(this.coordinate, this.timeStamp);
  
  SpaceTimePoint copyWith({LatLng? coordinate, DateTime? timeStamp}) {
    return SpaceTimePoint( coordinate ?? this.coordinate , timeStamp ?? this.timeStamp);
  }

  @override
  String toString() {
    return "SpaceTimeStamp(coordinate:$coordinate, timestamp: $timeStamp)";
  }

  Map<String, dynamic> toMap() {
    return {
      "coordinate": GeoPoint(coordinate.latitude, coordinate.longitude),
      "timestamp": timeStamp,
    };
  }

  static SpaceTimePoint fromMap(Map<String, dynamic> map) {
    GeoPoint geoPoint = map["coordinate"];
    LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
    Timestamp timestamp = map["timestamp"];
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    return SpaceTimePoint(latLng, time);
  }

}