import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smollar_dts/utils/services/auth.dart';
import '../models/device.dart';

final currentDeviceProvider = StateNotifierProvider<DeviceNotifier, Device?>((ref) => DeviceNotifier(null) );
final deviceProvider = StreamNotifierProvider<DeviceListNotifier, List<Device>>(DeviceListNotifier.new);
final userProvider = StreamProvider<User?>((ref) => AuthService().userStream);