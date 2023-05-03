import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/bus.dart';

class LocationStreamButton extends StatefulWidget {
  const LocationStreamButton({super.key});

  @override
  State<LocationStreamButton> createState() => _LocationStreamButtonState();
}

class _LocationStreamButtonState extends State<LocationStreamButton> {
  final auth = FirebaseAuth.instance.currentUser;
  final Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;
  bool _streaming = false;

  String name = '';
  String number = '';
  String from = '';
  String to = '';

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> getBusInfo() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('buses')
            .doc(auth!.uid)
            .get();

    setState(() {
      name = documentSnapshot['name'] as String;
      number = documentSnapshot['number'] as String;
      from = documentSnapshot['from'] as String;
      to = documentSnapshot['to'] as String;
    });
  }

  getLocation() async {
    try {
      final LocationData locationResult = await location.getLocation();
      await getBusInfo();
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(auth!.uid)
          .set({
        'latitude': locationResult.latitude,
        'longitude': locationResult.longitude,
        'name': name,
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> listenLocation() async {
    await requestPermission();
    await getLocation();
    setState(() {
      _streaming = true;
    });
    locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      locationSubscription?.cancel();
      locationSubscription = null;
    }).listen((LocationData currentlocation) async {
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(auth!.uid)
          .set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': name,
      }, SetOptions(merge: true));
    });
  }

  stopListening() {
    setState(() {
      _streaming = false;
    });
    locationSubscription?.cancel();
    locationSubscription = null;
  }

  requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: _streaming ? Colors.red : Colors.green,
      onPressed: _streaming ? stopListening : listenLocation,
      child: Icon(_streaming ? Icons.stop : Icons.play_arrow),
    );
  }
}
