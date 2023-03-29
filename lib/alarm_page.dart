import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final alarmSettings = AlarmSettings(
    id: 42,
    dateTime: DateTime(2023, 3, 28, 20, 43),
    assetAudioPath: 'assets/alarm.mp3',
    loopAudio: true,
    vibrate: true,
    fadeDuration: 3.0,
    notificationTitle: "Wake Up hustle time",
    notificationBody: '-------------------',
    enableNotificationOnKill: true,
  );

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await Alarm.init();
    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Alarm'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () async {
              await Alarm.stop(1);
            },
            child: Text('Cancel Alarm'),
          ),
        ));
  }
}
