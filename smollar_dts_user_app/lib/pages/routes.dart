import 'package:flutter/material.dart';

import 'home/home_page.dart';
import 'login/login_page.dart';

Map<String, Widget Function(BuildContext context)> routes = {
  "/home": (context) => const HomePage(),
  "/login": (context) => const LoginPage(),
};