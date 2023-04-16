import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smollar_dts/pages/login/login_page.dart';
import 'package:smollar_dts/utils/services/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/models/device.dart';
import '../../utils/services/providers.dart';


class Home extends ConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return user.when(
      data: (data) {
        if (data != null) {
          return const HomePage();
        }
        Navigator.pushNamed(context, "/login");
        return const Center(child: CircularProgressIndicator(),);
      },
      error: (error, stackTrace) {
        log(
          "Error in Home occured",
          error: error,
          stackTrace: stackTrace,
        );
        return const Center(child: Text("An Error occured"),);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smollar DTS"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().logout();
            },
          ),
        ],
        leading: const ProfilePicture(),
      ),
      body: const DeviceSelector(),
    );
  }
}

class DeviceSelector extends ConsumerWidget {
  const DeviceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Device>> deviceStream = ref.watch(deviceProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Available Devices:"),
        const Divider(
          thickness: 2,
        ),
        Expanded(
          child: deviceStream.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) {
              log("error", error: error, stackTrace: stackTrace);
              return Text(error.toString());
            },
            data: (data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => TextButton(
                onPressed: () {
                  ref.read(currentDeviceProvider.notifier).set(data[index]);
                  Navigator.pushNamed(context, "/device");
                },
                child: Text(data[index].deviceId),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePicture extends ConsumerWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return user.when(
      data: (data) {
        if (data!.isAnonymous) {
          return const CircleAvatar(child: Icon(Icons.supervised_user_circle),);
        }
        return CircleAvatar(
          backgroundImage: NetworkImage(data.photoURL!),
        );
      },
      error: (error, stackTrace) {
        log("Error occured in profilePicture", error: error, stackTrace: stackTrace);
        return const CircleAvatar(backgroundColor: Colors.red,);
      },
      loading: () => const CircularProgressIndicator(),
    );
  }
}