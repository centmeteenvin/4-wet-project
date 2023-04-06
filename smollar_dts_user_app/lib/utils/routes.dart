import 'package:flutter/material.dart';

import '../pages/home/home.dart';

Map<String, Widget Function(BuildContext context)> routes = {
  "/home" :  (context) => const HomePage(),
};