import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:location/location.dart';
import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
final uuidProvider = FutureProvider<String>((ref) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.get("UUID") == null) {
    preferences.setString("UUID", const Uuid().v4());
  }
  return preferences.getString("UUID")!;
});

final deviceNameProvider = StateProvider<String>(
  (ref) => "Empty Name",
);
final locationProvider = StateProvider<List<SpaceTimePoint>>((ref) => [],);
final isRegisterd = StateProvider<bool>((ref) => false);
final callBackProvider = StateProvider<bool>((ref) => false);

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if(await Permission.location.request().isGranted) {
    runApp(const ProviderScope(child: MyApp()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: "Smollar DTS Collar app",
      home: HomePage(),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends ConsumerWidget {
  Timer? timer;
  HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uuid = ref.watch(uuidProvider);
    final deviceName = ref.watch(deviceNameProvider);
    var backgroundColor = ref.watch(isRegisterd)
        ? Colors.purple.shade900
        : const ColorScheme.dark().background; 
    if (ref.watch(callBackProvider)) backgroundColor = Colors.red;
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
            FutureBuilder(
              future: Location.instance.getLocation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                else if (snapshot.hasError) {
                  return const Text("An error occured");
                }
                return Text("Current Location:\n${snapshot.data}");
              }
            ),
            TextButton(
              onPressed: () async {
                var uuidString = uuid.whenOrNull(data: (data) => data,)!;
                var response = await http.post(Uri.parse("https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuidString"), body: deviceName);
                if (response.statusCode == 201) {
                  ref.read(isRegisterd.notifier).state = true;
                  timer = Timer.periodic(const Duration(seconds: 2), (timer) => trackingTask(ref, uuidString));
                 }
              },
              child: const Text("Register Device"),
            ),
            TextButton(
              onPressed: () async {
                var uuidString = uuid.whenOrNull(data: (data) => data,)!;
                var response = await http.delete(Uri.parse("https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuidString"));
                if (response.statusCode == 200) {
                  ref.read(isRegisterd.notifier).state = false;
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
    List<SpaceTimePoint> locations = List.from(ref.read(locationProvider));
    SpaceTimePoint spaceTimePoint = SpaceTimePoint(await Location.instance.getLocation(), DateTime.now());
    log(spaceTimePoint.dateTime.toString());
    locations.add(spaceTimePoint);
    var response = await http.put(
      Uri.parse(
        "https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuidString"),
        headers: {"Content-type": "application/json"},
        body: json.encode(locations.map((e) => e.asMap()).toList()),
    );
    log(response.body);
    if (response.statusCode == 200) {
      locations = [];
      if (response.body == "true") {
        ref.read(callBackProvider.notifier).state = true;
        log("playing callback sound");
        await player.play(AssetSource("sound.mp3"));
      }

    }
    ref.watch(locationProvider.notifier).state = locations;
}
}
// Center(
//         child: Text(
//           uuid.maybeWhen(
//           orElse: () => "Loading",
//           data: (data) => data,
//         )
//         ),
//       )

class SpaceTimePoint {
  final LocationData location;
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

