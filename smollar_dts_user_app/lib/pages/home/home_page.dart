import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smollar_dts/pages/device/device_page.dart';
import 'package:smollar_dts/utils/services/auth.dart';
import 'package:smollar_dts/utils/services/firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/models/device.dart';
import 'device_selector.dart';

final currentDeviceProvider = StateNotifierProvider<DeviceNotifier, Device?>((ref) => DeviceNotifier(null) );

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()),);
        } else if (snapshot.hasData) {
          return const HomePage();
        }
        Navigator.pushNamed(context, "/login");
        return const Center(child: CircularProgressIndicator(),);
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smollar DTS"),
        centerTitle: true,
      ),
      body: const DeviceSelector(),
    );
  }
}
