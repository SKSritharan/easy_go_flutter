import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/bus.dart';
import '../../models/location.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  bool isBusExist = false;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyChUaxAEn2iG9rUmCne6kNU2MsK4_JGn60";

  @override
  void initState() {
    super.initState();
    _checkIfBusExists();
    _checkLocationPermission();
  }

  Future<void> _checkIfBusExists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('buses')
        .doc(user!.uid)
        .get();
    setState(() {
      isBusExist = snapshot.exists;
    });
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
        body: isBusExist
            ? SizedBox(
                height: size.height,
                width: size.width,
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('buses')
                      .doc(user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final name = snapshot.data!['name'] as String;
                      final number = snapshot.data!['number'] as String;
                      final fromLatLng = snapshot.data!['from'] as GeoPoint;
                      final toLatLng = snapshot.data!['to'] as GeoPoint;
                      final from =
                          LatLng(fromLatLng.latitude, fromLatLng.longitude);
                      final to = LatLng(toLatLng.latitude, toLatLng.longitude);

                      final bus = Bus(
                        id: user!.uid,
                        name: name,
                        number: number,
                        from: from,
                        to: to,
                      );

                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('locations')
                            .doc(user!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final name = snapshot.data!['name'] as String;
                            final latitude =
                                snapshot.data!['latitude'] as double;
                            final longitude =
                                snapshot.data!['longitude'] as double;

                            final busLocation = BusLocationData(
                              id: user!.uid,
                              name: name,
                              latitude: latitude,
                              longitude: longitude,
                            );

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
                              markers: {
                                Marker(
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueBlue,
                                  ),
                                  markerId: MarkerId(busLocation.id),
                                  position: LatLng(busLocation.latitude,
                                      busLocation.longitude),
                                  infoWindow:
                                      InfoWindow(title: busLocation.name),
                                ),
                              },
                              polylines: Set<Polyline>.of(
                                {
                                  Polyline(
                                    polylineId: PolylineId(busLocation.id),
                                    points: [from, to],
                                    patterns: [
                                      PatternItem.dash(20.0),
                                      PatternItem.gap(10)
                                    ],
                                    width: 3,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                },
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Center(
                        child: Center(
                          child: Text(
                              'Bus not added yet!, Please add one to continue.'),
                        ),
                      );
                    }
                  },
                ),
              )
            : const Center(
                child: Text('Bus not added yet!, Please add one to continue.'),
              ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isBusExist)
              FloatingActionButton(
                onPressed: _checkLocationPermission,
                child: const Icon(Icons.my_location),
              ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: () => addBusDetails(size),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            ),
            const SizedBox(
              height: 10,
            ),
            if (isBusExist) const LocationStreamButton(),
          ],
        ),
      ),
    );
  }

  void addBusDetails(size) {
    final controller = Get.put(DriverHomeController());
    Get.bottomSheet(
      Obx(
        () => SingleChildScrollView(
          child: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Form(
                  key: controller.formKey,
                  child: Container(
                    height: size.height * 0.65,
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Your Bus Here',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              hintText: 'Bus Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.directions_bus),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'The bus name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller.numberController,
                            decoration: InputDecoration(
                              hintText: 'Bus Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.directions_bus),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'The bus number is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller.fromController,
                            decoration: InputDecoration(
                              hintText: 'From',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.arrow_circle_up),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'The bus start stop is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller.toController,
                            decoration: InputDecoration(
                              hintText: 'To',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.arrow_circle_down),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'The bus destination stop is required';
                              }
                              return null;
                            },
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.submitForm,
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Submit'),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
