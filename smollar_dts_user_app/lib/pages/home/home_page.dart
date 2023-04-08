import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smollar_dts/utils/services/auth.dart';
import 'package:smollar_dts/utils/services/firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/models/device.dart';

final currentDeviceProvider = StateNotifierProvider<DeviceNotifier, Device?>((ref) => DeviceNotifier(null) );

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentDevice = ref.watch(currentDeviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smollar DTS"
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (currentDevice == null) return const DeviceSelector();
          return Text(currentDevice.deviceId);
        },
      ),
    );
  }
}

class DeviceSelector extends ConsumerWidget {
  const DeviceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Available Devices:"),
          const Divider(thickness: 2,),

          Expanded(
            child: FutureBuilder(
              future: FirestoreService().getAllDevices(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                    return TextButton(
                      onPressed: () {
                        Device device = snapshot.data![index];
                        ref.read(currentDeviceProvider.notifier).state = device;

                      },
                      child: Text(snapshot.data?[index].deviceName ?? "empty"),
                    );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return const CircularProgressIndicator();
              },
            ),
          )
        ],
      );
  }
}