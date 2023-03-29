import 'dart:ffi';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ref = FirebaseFirestore.instance.collection('ultimate-alarm-clock');
  final _activityStreamController = StreamController<Activity>();
  StreamSubscription<Activity>? _activityStreamSubscription;

  void _onActivityReceive(Activity activity) {
    dev.log('Activity Detected >> ${activity.toJson()}');
    _activityStreamController.sink.add(activity);
  }

  void _handleError(dynamic error) {
    dev.log('Catch Error >> $error');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final activityRecognition = FlutterActivityRecognition.instance;

      // Check if the user has granted permission. If not, request permission.
      PermissionRequestResult reqResult;
      reqResult = await activityRecognition.checkPermission();
      if (reqResult == PermissionRequestResult.PERMANENTLY_DENIED) {
        dev.log('Permission is permanently denied.');
        return;
      } else if (reqResult == PermissionRequestResult.DENIED) {
        reqResult = await activityRecognition.requestPermission();
        if (reqResult != PermissionRequestResult.GRANTED) {
          dev.log('Permission is denied.');
          return;
        }
      }

      // Subscribe to the activity stream.
      _activityStreamSubscription = activityRecognition.activityStream
          .handleError(_handleError)
          .listen(_onActivityReceive);
    });
  }

  void _startTimer() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      var documentSnapshot = await ref.doc('user-1').get();

      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      var lastInteraction = data['last_interaction'];

      if (lastInteraction == Null) {
        return;
      }

      final idleTime = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastInteraction))
          .inMinutes;
      if (idleTime >= 1) {
        // User is idle for 1 minute
      }
    });
  }

  void _updateLastActiveTime() {
    ref.doc('user-1').update({
      'last_interaction': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('This is your app content'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _updateLastActiveTime();
          // ... Your existing FAB code here
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
