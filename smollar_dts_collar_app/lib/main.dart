import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smollar_dts_collar_app/models/settings.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';

import 'home.dart';
import 'models/fence.dart';
import 'models/spaceTimePoint.dart';

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
final currentLocationProvider = NotifierProvider<LocationNotifier, LocationData?>(LocationNotifier.new);
final locationProvider = StateProvider<List<SpaceTimePoint>>((ref) => [],);
final isRegisterdProvider = StateProvider<bool>((ref) => false);
final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
final fenceProvider = StateProvider<Fence?>((ref) => null);
final distanceProvider = StateProvider<double>((ref) => 0,);

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
      home: const HomePage(),
    );
  }
}

// ignore: must_be_immutable
// Center(
//         child: Text(
//           uuid.maybeWhen(
//           orElse: () => "Loading",
//           data: (data) => data,
//         )
//         ),
//       )

