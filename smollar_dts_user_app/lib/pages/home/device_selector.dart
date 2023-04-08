import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smollar_dts/utils/models/device.dart';
import 'package:smollar_dts/utils/services/firestore.dart';

import 'home_page.dart';

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
                        ref.read(currentDeviceProvider.notifier).set(device);
                        Navigator.pushNamed(context, "/device");
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