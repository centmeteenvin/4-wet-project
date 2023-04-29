import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smollar_dts/utils/models/fence.dart';
import 'package:smollar_dts/utils/services/auth.dart';
import 'package:smollar_dts/utils/services/firestore.dart';
import '../models/device.dart';

final currentDeviceProvider = NotifierProvider<DeviceNotifier, Device?>(DeviceNotifier.new);
final deviceProvider = StreamNotifierProvider<DeviceListNotifier, List<Device>>(
    DeviceListNotifier.new);
final userProvider = StreamProvider<User?>((ref) => AuthService().userStream);

class DeviceListNotifier extends StreamNotifier<List<Device>> {
  @override
  Stream<List<Device>> build() {
    return FirestoreService().getAllDevicesStream();
  }
}

class DeviceNotifier extends Notifier<Device?> {

  void set(Device device) {
    state = device;
    FirestoreService().getDeviceStream(state!.deviceId).listen((event) {if (event != null) state = event;});
  }

  void comeBack() {
    bool comeback = state!.comeBack;
    state = state!.copyWith(comeBack: !comeback);
    state!.update();
  }

  void updateFence(Fence fence) {
    state = state!.copyWith(fence: fence);
    state!.update();
  }
  
  @override
  Device? build() {
    return null;
  }
}
