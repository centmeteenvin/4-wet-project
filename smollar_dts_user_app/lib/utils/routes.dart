import 'package:flutter/material.dart';
import 'package:smollar_dts/pages/device/device_page.dart';

import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';

Map<String, Widget Function(BuildContext context)> routes = {
  "/home": (context) => const Home(),
  "/login": (context) => const LoginPage(),
  "/device": (context) => const DevicePage(),
};