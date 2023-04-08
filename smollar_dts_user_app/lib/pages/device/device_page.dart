import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smollar_dts/pages/home/home_page.dart';
import 'package:smollar_dts/utils/models/device.dart';
import 'package:smollar_dts/utils/models/space_time_point.dart';

class DevicePage extends ConsumerWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Device device = ref.watch(currentDeviceProvider.select((value) => value!,)); 
    return Scaffold(
      appBar: AppBar(
        title: Text(
          device.deviceId
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (device.locations.isNotEmpty) const GoogleMapsWidget()
          else const Text("No location information available"),
          Text(device.deviceName)
        ],
      ),
    );
  }
}

class GoogleMapsWidget extends ConsumerWidget {
  const GoogleMapsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SpaceTimePoint> locations = ref.watch(currentDeviceProvider.select((value) => value!.locations));
    var size = MediaQuery.of(context).size;
    return  SizedBox(
      height: size.height / 2,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(51, 4), zoom: 11),
        
        markers: {
          Marker(
            markerId: MarkerId(locations.last.timeStamp.toString()),
            position: locations.last.coordinate ?? const LatLng(0, 0),
          )
        },
      ),
    );
  }
}