import 'package:flutter/material.dart';
import 'package:smollar_dts/utils/auth/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => AuthService().signInWithGoogle(),
             child: const Text(
              "Sign in with Google"
             ), 
          ),

          TextButton(
            onPressed: () => AuthService().signInAnonymous(),
            child: const Text(
              "Sign in Anonymously"
            ),
          ),
        ],
      ),
    );
  }
}