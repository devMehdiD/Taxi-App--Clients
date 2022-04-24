import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class Fcm {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final datactrl = StreamController<String>.broadcast();
  final titlectrl = StreamController<String>.broadcast();
  final bodyctrl = StreamController<String>.broadcast();

  setNotificationSettings() async {
    NotificationSettings notificationSettings =
        await firebaseMessaging.requestPermission(
            alert: true, badge: true, sound: true, provisional: false);
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      // ignore: avoid_print
      print("Permision Granted");
      forGroundNotification();
      backGroundNotification();
      terminatedNotification();
    }
  }

  void terminatedNotification() async {
    RemoteMessage? remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      if (remoteMessage.data.isNotEmpty) {
        datactrl.sink.add("event.data");
      }
      if (remoteMessage.notification != null) {
        titlectrl.sink.add(remoteMessage.notification!.title!);
        bodyctrl.sink.add(remoteMessage.notification!.body!);
      }
    }
  }

  void forGroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.data.isNotEmpty) {
        datactrl.sink.add("event.data");
      }
      if (event.notification != null) {
        titlectrl.sink.add(event.notification!.title!);
        bodyctrl.sink.add(event.notification!.body!);
      }
    });
  }

  void backGroundNotification() {
    FirebaseMessaging.onMessage.listen((event) {
      if (event.data.isNotEmpty) {
        datactrl.sink.add("event.data");
      }
      if (event.notification != null) {
        titlectrl.sink.add(event.notification!.title!);
        bodyctrl.sink.add(event.notification!.body!);
      }
    });
  }

  @override
  // ignore: override_on_non_overriding_member
  void dispose() {
    datactrl.close();
    titlectrl.close();
    bodyctrl.close();
  }
}
