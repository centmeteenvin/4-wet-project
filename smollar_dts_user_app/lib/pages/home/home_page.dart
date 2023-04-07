import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smollar_dts/utils/auth/auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    User user = AuthService().user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smollar DTS"
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(user.toString()),
          TextButton(
            onPressed: () => AuthService().logout(),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}