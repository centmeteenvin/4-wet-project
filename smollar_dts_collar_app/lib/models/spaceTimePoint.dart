// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';
import 'package:smollar_dts_collar_app/main.dart';

import 'fence.dart';

class SpaceTimePoint {
  final Position location;
  final DateTime dateTime;

  SpaceTimePoint(this.location, this.dateTime);

  Map<String, dynamic> asMap() {
    return {
      "timestamp": {
        "seconds": dateTime.millisecondsSinceEpoch/1000,
        "nanos":0,
      },
      "coordinate": {
        "latitude": location.latitude,
        "longitude": location.longitude,
      },
    };
  } 
}

class LocationNotifier extends Notifier<Position?> {
  @override
  Position? build() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) { 
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((value) async {
        state = value;
        Fence? fence = ref.read(fenceProvider);
        if (fence != null) {
          var distance = calculateDistance(value, fence.anchor);
          ref.read(distanceProvider.notifier).state = distance;
          if ( ref.read(settingsProvider).fenceIsActive && distance >= fence.distance) {
            await ref.read(settingsProvider.notifier).comeBack();
          }
        }
      });
    });
    return null;
  }

}

double calculateDistance(Position coordinate1, Position coordinate2) {
  return GreatCircleDistance.fromDegrees(latitude1: coordinate1.latitude, longitude1:  coordinate1.longitude, latitude2: coordinate2.latitude, longitude2: coordinate2.longitude).vincentyDistance();
}