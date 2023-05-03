import 'dart:async';
import 'dart:developer';
import 'dart:math' as m;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smollar_dts/utils/models/device.dart';
import 'package:smollar_dts/utils/models/space_time_point.dart';
import 'package:smollar_dts/utils/services/firestore.dart';

import '../../utils/models/fence.dart';
import '../../utils/services/providers.dart';

class DevicePage extends ConsumerWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String deviceId =
        ref.read(currentDeviceProvider.select((value) => value!.deviceId));
    Stream<Device?> deviceStream = FirestoreService().getDeviceStream(deviceId);
    return StreamBuilder(
      stream: deviceStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error!);
        }
        if (snapshot.data == null) {
          Navigator.maybePop(context);
          return ErrorWidget("Device is gone");
          
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: const [
                Expanded(
                  flex: 2,
                  child: TrackingMap(),
                ),
                Flexible(
                  flex: 1,
                  child: CallBackButton(),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: FenceEditor(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrackingMap extends ConsumerWidget {
  const TrackingMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Completer<GoogleMapController> controller = Completer();
    String currentDeviceId =
        ref.watch(currentDeviceProvider.select((device) => device!.deviceId));
    Set<Marker> markers;
    return StreamBuilder(
      stream: FirestoreService().getDeviceStream(currentDeviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          log("error has occured");
          return Center(
            child: ErrorWidget(snapshot.error!),
          );
        }
        if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        Device device = snapshot.data!;
        List<SpaceTimePoint> locations = device.locations;
        if (locations.isEmpty) {
          return ErrorWidget("No Data to display");
        }
        locations.sort(
          (a, b) => a.timeStamp.compareTo(b.timeStamp),
        );
        controller.future.then((value) => value.animateCamera(CameraUpdate.newCameraPosition(calculatePosition(locations.last.coordinate, device.fence.anchor))));
        markers = {
          Marker(
            markerId: MarkerId(device.deviceId),
            position: device.locations.last.coordinate,
            infoWindow: InfoWindow(
              title:
                  "${locations.last.timeStamp.hour}:${locations.last.timeStamp.minute}:${locations.last.timeStamp.second}",
              snippet: "Woof",
            ),
          ),
        };
        return GoogleMap(
          initialCameraPosition: calculatePosition(locations.last.coordinate, device.fence.anchor),
          markers: markers,
          polylines: {
            Polyline(
              polylineId: PolylineId(device.deviceId.toString()),
              points: locations
                  .map((spaceTimePoint) => spaceTimePoint.coordinate)
                  .toList(),
              color: Colors.purple,
              geodesic: true,
              jointType: JointType.round,
              width: 4,
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId("Fence"),
              center: device.fence.anchor,
              radius: device.fence.distance,
              fillColor: device.fence.inUse
                  ? Colors.orange.shade400.withAlpha(50)
                  : Colors.grey.shade600.withAlpha(50),
              strokeWidth: 4,
              strokeColor:
                  device.fence.inUse ? Colors.orange.shade900 : Colors.grey,
            ),
          },
        onMapCreated: (googleMapController) => controller.complete(googleMapController),
        );
      },
    );
  }
}

class CallBackButton extends ConsumerWidget {
  const CallBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Device currentDevice = ref.watch(currentDeviceProvider)!;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: currentDevice.comeBack ? Colors.red : Colors.blue,
      ),
      onPressed: () {
        log("Calling back");
        ref.read(currentDeviceProvider.notifier).comeBack();
      },
      child: Text(
        currentDevice.comeBack ? "Stop calling" : "Come Back!",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class FenceEditor extends ConsumerWidget {
  const FenceEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Device currentDevice = ref.watch(currentDeviceProvider)!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: currentDevice.fence.distance.toString(),
                hintStyle: const TextStyle(color: Colors.black)),
            onSubmitted: (value) async {
              Position locationData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
              LatLng latLng = LatLng(
                locationData.latitude,
                locationData.longitude,
              );
              double distance = double.parse(value);
              Fence fence = currentDevice.fence
                  .copyWith(anchor: latLng, distance: distance);
              ref.read(currentDeviceProvider.notifier).updateFence(fence);
            },
          ),
        ),
        Switch(
            value: currentDevice.fence.inUse,
            onChanged: (value) {
              Fence fence = currentDevice.fence.copyWith(inUse: value);
              ref.read(currentDeviceProvider.notifier).updateFence(fence);
            }),
      ],
    );
  }
}

double distance(LatLng coordinate1, LatLng coordinate2) {
  return m.sqrt(
      m.pow((coordinate2.latitude - coordinate1.latitude) * 110600, 2) +
          m.pow((coordinate2.longitude - coordinate1.longitude) * 110600, 2));
}

LatLng average(LatLng coordinate1, LatLng coordinate2) {
  var coord = LatLng(
    (coordinate1.latitude + coordinate2.latitude) * 0.5,
    (coordinate1.longitude + coordinate2.longitude) * 0.5,
  );
  log(coord.toString());
  return coord;
}

double calculateZoom(LatLng coordinate1, LatLng coordinate2) {
  double zoom =
      m.log(40000000 / (distance(coordinate1, coordinate2) * 1.2)) / m.ln2;
  log(zoom.toString());
  return zoom;
}

CameraPosition calculatePosition(LatLng coordinate1, LatLng coordinate2) {
  return CameraPosition(
    target: average(coordinate1, coordinate2),
    zoom: calculateZoom(coordinate1, coordinate2),
  );
}