import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
import 'models/fence.dart';
import 'models/settings.dart';
import 'models/spaceTimePoint.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    final uuid = ref.watch(uuidProvider);
    final deviceName = ref.watch(deviceNameProvider);
    final settings = ref.watch(settingsProvider);
    final isRegisterd = ref.watch(isRegisterdProvider);
    var backgroundColor = isRegisterd
        ? Colors.purple.shade900
        : const ColorScheme.dark().background;
    if (settings.fenceIsActive && isRegisterd) backgroundColor = Colors.green.shade600;
    if (settings.comeBack && isRegisterd) backgroundColor = Colors.red;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Collar Application"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              uuid.maybeWhen(
                orElse: () => "Loading",
                data: (data) => "Unique Identifier: $data",
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: deviceName,
                hintStyle: const TextStyle(color: Colors.white),
              ),
              onSubmitted: (value) {
                ref.read(deviceNameProvider.notifier).state = value;
              },
            ),
            const CurrentLocationWidget(),
            const FenceDataWidget(),
            TextButton(
              onPressed: () async {
                var uuidString = uuid.whenOrNull(
                  data: (data) => data,
                )!;
                var response = await http.post(
                    Uri.parse(
                        "https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuidString"),
                    body: deviceName);
                if (response.statusCode == 201) {
                  ref.read(isRegisterdProvider.notifier).state = true;
                  ref.read(settingsProvider.notifier).fetchSettings();
                  timer = Timer.periodic(const Duration(seconds: 2),
                      (timer) => trackingTask(ref, uuidString));
                }
              },
              child: const Text("Register Device"),
            ),
            TextButton(
              onPressed: () async {
                var uuidString = uuid.whenOrNull(
                  data: (data) => data,
                )!;
                var response = await http.delete(Uri.parse(
                    "https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuidString"));
                if (response.statusCode == 200) {
                  ref.read(isRegisterdProvider.notifier).state = false;
                  timer!.cancel();
                }
              },
              child: const Text("Delete Device"),
            ),
          ],
        ),
      ),
    );
  }

  void trackingTask(WidgetRef ref, String uuidString) async {

    //getting initialState
    String baseUri = "https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuidString";
    int fenceId = ref.read(settingsProvider.select((value) => value.fenceId));
    List<SpaceTimePoint> locations = List.from(ref.read(locationProvider));

    //getting current LocationcurrentLocation
    LocationData currentLocation= ref.read(currentLocationProvider)!;
    SpaceTimePoint spaceTimePoint = SpaceTimePoint(ref.read(currentLocationProvider)!, DateTime.now());
    log(spaceTimePoint.dateTime.toString());
    locations.add(spaceTimePoint);

    //updateing resource with data
    try {
    var response = await http.put(
      Uri.parse("https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuidString"),
      headers: {"Content-type": "application/json"},
      body: json.encode(locations.map((e) => e.asMap()).toList()),
    );
    log(response.body);

    //checking response
    if (response.statusCode == 200) {
      locations = [];
      Settings settings = Settings.fromString(response.body);
      ref.read(settingsProvider.notifier).set(settings);

      //callback
      if (settings.comeBack) {
        ref.read(settingsProvider.notifier).comeBack();
      }

      //fetch fence if necesarry
      if (settings.fenceId != fenceId) {
        var response = await http.get(Uri.parse("$baseUri/fence"));
        Fence fence = Fence.fromMap(json.decode(response.body));
        fenceId = settings.fenceId;
        ref.read(fenceProvider.notifier).state = fence;
      }
    }
    ref.watch(locationProvider.notifier).state = locations;
    } on Exception {
      return;
    }
  }
}

class CurrentLocationWidget extends ConsumerWidget {
  const CurrentLocationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentLocation =  ref.watch(currentLocationProvider);
    if(currentLocation == null) {
      return const Center(child: CircularProgressIndicator(),);
    }
    return Text(
      "CurrentLocation:${currentLocation.latitude}|${currentLocation.longitude}"
    );
  }
}

class FenceDataWidget extends ConsumerWidget {
  const FenceDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var fence =ref.watch(fenceProvider);
    var distance = ref.watch(distanceProvider);
    if (fence == null) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("Current Anchor:${fence.anchor.latitude}|${fence.anchor.latitude}"),
        Text("Current Range:${fence.distance}"),
        Text("Current distance from anchor:\n$distance")
      ],
    );
  }
}