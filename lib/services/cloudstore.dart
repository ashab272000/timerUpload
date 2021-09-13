import 'package:mettrial/models/timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudStore {
  static final CloudStore _singleton = CloudStore._internal();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  factory CloudStore() {
    return _singleton;
  }

  CloudStore._internal();

  Future<void> addTimer(MetTimer timer) async {
    await firestore.collection('timers').doc('hello').set({
      'start_time': timer.startTime,
      'end_time': timer.endTime,
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getTimer() {
    return firestore.collection('timers').doc('hello').snapshots();
  }
}
