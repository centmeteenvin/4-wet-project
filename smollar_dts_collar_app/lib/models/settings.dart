import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:smollar_dts_collar_app/main.dart';

@immutable
class Settings {
  final bool comeBack;
  final bool fenceIsActive;
  final int fenceId;

  const Settings(this.comeBack, this.fenceIsActive, this.fenceId);

  static Settings fromString(String code) {
    List<String> codeArray = code.split('');
    return Settings(
      codeArray[0] == '1' ? true : false,
      codeArray[1] == '1' ? true : false,
      int.parse(codeArray[2]),
    );
  }

  Settings copyWith({bool? comeBack, bool? fenceIsActive, int? fenceId}) {
    return Settings(
      comeBack ?? this.comeBack,
      fenceIsActive ?? this.fenceIsActive,
      fenceId ?? this.fenceId,
    );
  }
}

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    return const Settings(false, false, -1);
  }

  void fetchSettings() async {
    String uuid = await ref.watch(uuidProvider.future);
    var response = await http.put(
        Uri.parse(
            "https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/$uuid"),
        headers: {"Content-type": "application/json"},
        body: json.encode([]),
      );
    state = Settings.fromString(response.body);
  }

  void set(Settings settings) {
    state = settings;
  }

  Future<void> comeBack() async {
    state = state.copyWith(comeBack: true);
    await player.play(AssetSource("sound.mp3"));
  }


}