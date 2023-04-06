import 'package:flutter/material.dart';

import 'home/homePage.dart';
import 'login/loginPage.dart';

Map<String, Widget Function(BuildContext context)> routes = {
  "/home": (context) => const HomePage(),
  "/login": (context) => const LoginPage(),
};