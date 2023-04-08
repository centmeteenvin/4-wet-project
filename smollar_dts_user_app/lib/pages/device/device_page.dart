import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smollar_dts/pages/home/home_page.dart';
import 'package:smollar_dts/utils/models/device.dart';
import 'package:smollar_dts/utils/models/space_time_point.dart';
import 'package:smollar_dts/utils/services/firestore.dart';

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
          return const Center(child: CircularProgressIndicator(),);
        } else if ( snapshot.hasError) {
          log("Error Occured", error: snapshot.error);
          return Text(snapshot.error.toString());
        }
        List<SpaceTimePoint> data = snapshot.data!;
        if (data.isEmpty) {
          return Text("No Data To Display");
        }
        Set<Marker> markers = {};
        _controller.future.then((googleMapController) => googleMapController.animateCamera(CameraUpdate.newLatLng(data.last.coordinate!)));
        for (var element in data) {
          markers.add(Marker(
            markerId: MarkerId(element.timeStamp!.toString()),
            position: element.coordinate!,
            infoWindow: InfoWindow(
              title: element.timeStamp?.toIso8601String(),
            )
          ));  
        }
        return GoogleMap(
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
          onMapCreated: (mapController) => _controller.complete(mapController),
        );
      },
    );
  }
}