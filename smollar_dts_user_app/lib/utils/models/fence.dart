import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


@immutable
class Fence {
  final LatLng anchor;
  final double distance;
  final bool inUse;

  const Fence({required this.anchor, required this.distance, this.inUse = false});
  
  Fence copyWith({LatLng? anchor, double? distance, bool? inUse }) {
    return Fence(
      anchor: anchor ?? this.anchor,
      distance: distance ?? this.distance,
      inUse: inUse ?? this.inUse,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "anchor": GeoPoint(anchor.latitude, anchor.longitude),
      "distance": distance,
      "inUse": inUse,
    };
  }
  static Fence fromMap(Map<String, dynamic> map) {
    GeoPoint geoPoint = map["anchor"] as GeoPoint;
    return Fence(
      anchor: LatLng(geoPoint.latitude, geoPoint.longitude),
      distance: map["distance"],
      inUse: map["inUse"],
    );
  }
}
