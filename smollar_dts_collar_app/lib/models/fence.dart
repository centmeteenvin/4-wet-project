import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

@immutable
class Fence {
  final Position anchor;
  final double distance;
  final bool inUse;

  const Fence({required this.anchor, required this.distance, required this.inUse});

  static Fence fromMap(Map<String, dynamic> map) {
    return Fence(
      anchor: Position.fromMap(map["anchor"]),
      distance: map["distance"],
      inUse: map["inUse"]
    );
  }
}