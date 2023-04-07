import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smollar_dts/utils/services/auth.dart';
import 'package:smollar_dts/utils/services/firestore.dart';

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
          const Text("Available Devices:"),
          const Divider(thickness: 2,),

          Expanded(
            child: FutureBuilder(
              future: FirestoreService().getAllDevices(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Text(snapshot.data![index]);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return const CircularProgressIndicator();
              },
            ),
          )
        ],
      ),
    );
  }
}