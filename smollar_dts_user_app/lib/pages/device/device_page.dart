import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smollar_dts/utils/models/device.dart';
import 'package:smollar_dts/utils/models/space_time_point.dart';
import 'package:smollar_dts/utils/services/firestore.dart';
import 'package:location/location.dart';

import '../../utils/services/providers.dart';

class DevicePage extends ConsumerStatefulWidget {
  const DevicePage({super.key});

  @override
  ConsumerState<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends ConsumerState<DevicePage> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    Device? _currentDevice = ref.watch(currentDeviceProvider);

    if (_currentDevice == null) {
      Navigator.pop(context);
    }
    Device currentDevice = _currentDevice!;

    return StreamBuilder(
      stream: FirestoreService().getLocationsStream(currentDevice.deviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          log("Error Occured", error: snapshot.error);
          return Text(snapshot.error.toString());
        }
        List<SpaceTimePoint> data = snapshot.data!;
        if (data.isEmpty) {
          return const Text("No Data To Display");
        }
        data.sort(
          (a, b) {
            return a.timeStamp!.compareTo(b.timeStamp!);
          },
        );
        Set<Marker> markers = {};
        markers.add(Marker(
          markerId: const MarkerId("Latest"),
          position: data.last.coordinate!,
          infoWindow: InfoWindow(
            title:
                "${data.last.timeStamp!.hour}:${data.last.timeStamp!.minute}:${data.last.timeStamp!.second}",
            snippet: "Woof",
          ),
        ));
        _controller.future.then((googleMapController) => googleMapController
            .animateCamera(CameraUpdate.newLatLng(data.last.coordinate!)));
        // for (var element in data) {
        //   markers.add(Marker(
        //     markerId: MarkerId(element.timeStamp!.toString()),
        //     position: element.coordinate!,
        //     infoWindow: InfoWindow(
        //       title: element.timeStamp?.toIso8601String(),
        //     )
        //   ));
        // }

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: data.last.coordinate!,
                    zoom: 11,
                  ),
                  markers: markers,
                  polylines: {
                    Polyline(
                      polylineId: PolylineId(currentDevice.deviceId.toString()),
                      points: data.map((e) => e.coordinate!).toList(),
                      color: Colors.purple,
                      geodesic: true,
                      jointType: JointType.round,
                      width: 4,
                    ),
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId("Fence"),
                      center: _currentDevice.fence.anchor,
                      radius: _currentDevice.fence.distance,
                      fillColor: _currentDevice.fence.inUse ?  Colors.orange.shade400.withAlpha(50) : Colors.grey.shade600.withAlpha(50),
                      strokeWidth: 4,
                      strokeColor: _currentDevice.fence.inUse ? Colors.orange.shade900 : Colors.grey,
                    ),
                  },
                  onMapCreated: (mapController) =>
                      _controller.complete(mapController),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextButton(
                  child: const Text("Come back!"),
                  onPressed: () {
                    _currentDevice.callBack();
                  },
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: _currentDevice.fence.distance.toString(),
                              hintStyle: const TextStyle(color: Colors.black)),
                          onSubmitted: (value) async {
                            var currentLocation1 =
                                await Location.instance.getLocation();
                            LatLng currentLocation2 = LatLng(
                                currentLocation1.latitude!,
                                currentLocation1.longitude!);
                            double distance = double.parse(value);
                            _currentDevice.setFence(Fence(
                                anchor: currentLocation2, distance: distance));
                          },
                        ),
                      ),
                      Switch(
                          value: _currentDevice.fence.inUse,
                          onChanged: (value) {
                            Fence fence = _currentDevice.fence;
                            fence.inUse = value;
                            _currentDevice.setFence(fence);
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
