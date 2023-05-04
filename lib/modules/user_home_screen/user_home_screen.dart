import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/location.dart';
import '../../routes/app_routes.dart';
import './controller/user_home_controller.dart';
import '../../utils/constants.dart' as constants;

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  GoogleMapController? mapController;
  Location location = Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = Map<PolylineId, Polyline>.fromIterable(
    [],
    key: (polyline) => PolylineId(polyline.polylineId),
    value: (polyline) => polyline,
  );

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

    return GetBuilder<UserHomeController>(
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
                FirebaseFirestore.instance.collection('locations').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final buses = snapshot.data!.docs.map((doc) {
                  final latitude = doc['latitude'] as double;
                  final longitude = doc['longitude'] as double;
                  final name = doc['name'] as String;

                  return BusLocationData(
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
                  markers: buses
                      .map(
                        (bus) => Marker(
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                            markerId: MarkerId(bus.id),
                            position: LatLng(bus.latitude, bus.longitude),
                            infoWindow: InfoWindow(title: bus.name),
                            onTap: () async {
                              List<LatLng> polylineCoordinates = [];
                              CollectionReference busesData = FirebaseFirestore
                                  .instance
                                  .collection('buses');
                              final busData = await busesData.doc(bus.id).get();
                              final fromLatLng = busData['from'] as GeoPoint;
                              final toLatLng = busData['to'] as GeoPoint;
                              final from = LatLng(
                                  fromLatLng.latitude, fromLatLng.longitude);
                              final to =
                                  LatLng(toLatLng.latitude, toLatLng.longitude);

                              PolylineResult result = await polylinePoints
                                  .getRouteBetweenCoordinates(
                                constants.googleMapAPiKey,
                                PointLatLng(from.latitude, from.longitude),
                                PointLatLng(to.latitude, to.longitude),
                                travelMode: TravelMode.driving,
                              );
                              if (result.points.isNotEmpty) {
                                result.points.forEach((PointLatLng point) {
                                  polylineCoordinates.add(
                                      LatLng(point.latitude, point.longitude));
                                });
                              } else {
                                print(result.errorMessage);
                              }

                              setState(() {
                                polylines.clear();
                                PolylineId id = PolylineId(bus.id);
                                Polyline polyline = Polyline(
                                    polylineId: id,
                                    points: polylineCoordinates,
                                    width: 8,
                                    color: Theme.of(context).primaryColor);
                                polylines[id] = polyline;
                              });
                            }),
                      )
                      .toSet(),
                  polylines: Set<Polyline>.of(polylines.values),
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
            FloatingActionButton(
              onPressed: () {
                Get.bottomSheet(
                  Container(
                    height: size.height * 0.3,
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Where are you going?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Enter your destination',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.directions),
            ),
          ],
        ),
      ),
    );
  }
}
