import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smollar_dts/utils/models/device.dart';
import 'package:smollar_dts/utils/services/firestore.dart';

import 'home_page.dart';

class DeviceSelector extends ConsumerWidget {
  const DeviceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Device>> deviceStream = ref.watch(deviceProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Available Devices:"),
        const Divider(
          thickness: 2,
        ),
        Expanded(
          child: deviceStream.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) {
              log("error", error: error, stackTrace: stackTrace);
              return Text(error.toString());
            },
            data: (data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => TextButton(
                onPressed: () {
                  ref.read(currentDeviceProvider.notifier).set(data[index]);
                  Navigator.pushNamed(context, "/device");
                },
                child: Text(data[index].deviceId),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
