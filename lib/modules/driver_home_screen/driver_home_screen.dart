import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/bus.dart';
import '../../routes/app_routes.dart';
import '../../utils/widgets/location_stream_button.dart';
import './controller/driver_home_controller.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  GoogleMapController? mapController;
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_locationData!.latitude!, _locationData!.longitude!),
            14,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GetBuilder<DriverHomeController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('EasyGo'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 1,
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    child: Text("Profile"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text("Logout"),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 1) {
                  Get.toNamed(AppRoutes.userProfileScreen);
                } else if (value == 2) {
                  FirebaseAuth.instance.signOut();
                  Get.offAndToNamed(AppRoutes.signInScreen);
                }
              },
            ),
          ],
        ),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('location').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final buses = snapshot.data!.docs.map((doc) {
                  final latitude = doc['latitude'] as double;
                  final longitude = doc['longitude'] as double;
                  final name = doc['name'] as String;

                  return Bus(
                    id: doc.id,
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                  );
                }).toList();

                return GoogleMap(
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    setState(() {
                      mapController = controller;
                    });
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(7.8731, 80.7718),
                    zoom: 7,
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _checkLocationPermission,
              child: const Icon(Icons.my_location),
            ),
            const SizedBox(
              height: 10,
            ),
            
            LocationStreamButton(),
          ],
        ),
      ),
    );
  }
}
