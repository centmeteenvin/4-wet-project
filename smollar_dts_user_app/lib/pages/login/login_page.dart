import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smollar_dts/utils/services/auth.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "Welcome To Smollar DTS",
              style: TextStyle(
                fontSize: 20
              ),
              textAlign: TextAlign.center,
            ),
          ),

          TextButton(
            onPressed: () {
              AuthService().signInWithGoogle();
            },
             child: const Text(
              "Sign in with Google"
             ), 
          ),

          TextButton(
            onPressed: () {
              AuthService().signInAnonymous();
            },
            child: const Text(
              "Sign in Anonymously"
            ),
          ),
        ],
      ),
    );
  }
}