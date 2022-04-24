// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UberStateManegment extends ChangeNotifier {
  double second = 0;
  late Timer timer;
  late Timer timerTue;
  double seconsTue = 60;
  int dateTime = DateTime.now().millisecondsSinceEpoch;
  String message = "Watting to Driver Confirm ...";
  bool showTimer = false;
  Completer<GoogleMapController> controller = Completer();
  TextEditingController locationcontroller = TextEditingController();
  TextEditingController goTo = TextEditingController();
  final driver = FirebaseFirestore.instance.collection("drivers").get();
  double drLat = 0.0;
  String drName = '';
  double drLong = 0.0;
  String clName = '';
  String drId = '';
  double latitudeClinet = 0.0;
  double longitudeClinet = 0.0;

  int selctedIndex = 0;
  String titel = "";
  Map<String, dynamic> data = {};
  final auth = FirebaseAuth.instance.currentUser!.uid;
  Set<Marker> marker = {};
  List<String> drivers = [];
  bool serviceEnabled = false;
  LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, distanceFilter: 1);
  Future<Position> determinePosition() async {
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    notifyListeners();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    GoogleMapController controll = await controller.future;
    controll.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
    marker.add(Marker(
        markerId: const MarkerId("user"),
        position: LatLng(position.latitude, position.longitude)));
    notifyListeners();
    await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude)
        .then((value) {
      locationcontroller.text =
          "${value.first.name}-${value.first.locality}-${value.first.country}";

      return value;
    });

    notifyListeners();
    return await Geolocator.getCurrentPosition();
  }

  updatePostion() {
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((event) async {
      // ignore: unnecessary_null_comparison
      if (event != null) {
        await FirebaseFirestore.instance
            .collection("client")
            .doc(auth)
            .update({"lat": event.latitude, "long": event.longitude});
        latitudeClinet = event.latitude;
        longitudeClinet = event.longitude;
        marker.add(Marker(
            markerId: const MarkerId("user"),
            position: LatLng(event.latitude, event.longitude)));
        notifyListeners();
      } else {
        print('null');
      }
    });
  }

  addMarker(LatLng latLng) async {
    marker.add(Marker(
        markerId: const MarkerId("goTo"),
        position: LatLng(latLng.latitude, latLng.longitude),
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/to.png")));
    await GeocodingPlatform.instance
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude)
        .then((value) {
      goTo.text =
          "${value.first.name}-${value.first.locality}-${value.first.country}";
    });
    notifyListeners();
  }

  getAllDrivers() async {
    QuerySnapshot<Map<String, dynamic>> allDrivers =
        await FirebaseFirestore.instance.collection("drivers").get();
    for (var element in allDrivers.docs) {
      drivers.add(element.data()['name']);
      notifyListeners();
    }
  }

  sendRequist(
      {required String driverName,
      required String driverId,
      required String clientId,
      required String fromlocation,
      required String tolocation,
      required String clientName,
      required double latClient,
      required double longClient,
      required double latDriver,
      required double longDriver}) async {
    var serverkey =
        "AAAAFFywNXo:APA91bFyg31YoUj3JaO9KSu14lIPlqFdfR-2bOLMxonPL2tgFUU4Ardjvs7LJCgd-pb5VdF0_eY5VCo_GGJ6o-7-ohEB9-cxDf_OZ2rhGV1-TZDuboTeplQ_hAYRrt4ORfaRiIO5uiFY";

    try {
      DocumentSnapshot<Map<String, dynamic>> driverDoucument =
          await FirebaseFirestore.instance
              .collection("drivers")
              .doc(drId)
              .get();

      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverkey',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'From $fromlocation to $tolocation',
            'title': 'New Client',
            'name': clientName
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            "title": 'New Client',
            "body": tolocation
          },
          'to': driverDoucument['token'],
        }),
      );

      createRelationBetwenClientandDrivers(
          clientId: clientId,
          driverId: driverId,
          latClient: latClient,
          longClient: longClient,
          latDriver: latDriver,
          longDriver: longDriver);
      showTimer = true;
      notifyListeners();
    } catch (e) {
      print("==========error= $e");
    }
  }

  createRelationBetwenClientandDrivers(
      {required String clientId,
      required String driverId,
      required double latClient,
      required double longClient,
      required double latDriver,
      required double longDriver}) {
    FirebaseFirestore.instance.collection("relation").add({
      'clientId': clientId,
      'driverId': driverId,
      'response': 'no',
      'latClient': latClient,
      'longClient': longClient,
      'latDriver': latDriver,
      'longDriver': longDriver,
      'time': dateTime
    });
  }

  onChanged(index) {
    selctedIndex = index;
    notifyListeners();
  }

  addToVaribles(String drname, drlat, drlong, drid) {
    drName = drname;
    drLat = drlat;
    drLong = drlong;
    drId = drid;
  }

  incrementTimer() {
    seconsTue = 60;
    notifyListeners();
    timerTue = Timer.periodic(const Duration(seconds: 1), (secondTimer) {
      if (seconsTue != 0) {
        seconsTue--;
        notifyListeners();
      } else {
        message = "Soryy Try again";
        timerTue.cancel();

        showTimer = false;
        deletDocForUser();
        notifyListeners();
      }
    });
  }

  lesnerToStatus() {
    FirebaseFirestore.instance
        .collection('relation')
        .where('clientId', isEqualTo: auth)
        .snapshots(includeMetadataChanges: true)
        .listen((event) {
      for (var element in event.docs) {
        print(element.data());
      }
    });
  }

  deletDocForUser() async {
    QuerySnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
        .collection('relation')
        .where('clientId', isEqualTo: auth)
        .get();
    for (var element in doc.docs) {
      if (element.data()['response'] == 'no') {
        element.reference.delete();
      } else {
        marker.add(Marker(
            markerId: MarkerId('driver'),
            position: LatLng(
                element.data()['latDriver'], element.data()['longDriver']),
            icon: await BitmapDescriptor.fromAssetImage(
                ImageConfiguration(), 'assets/driverlogo.png')));
        notifyListeners();
      }
    }
  }
}
