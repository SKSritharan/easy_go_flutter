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
import '../../utils/constants.dart' as constants;

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

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  void _getPolyline(PointLatLng from, PointLatLng to) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      constants.googleMapAPiKey,
      from,
      to,
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        width: 8,
        color: Theme.of(context).primaryColor);
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  void initState() {
    _checkLocationPermission();
    super.initState();
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
            IconButton(
              onPressed: () {
                Get.toNamed(AppRoutes.userProfileScreen);
              },
              icon: const Icon(Icons.account_circle),
            ),
          ],
        ),
        body: SizedBox(
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
                final from = LatLng(fromLatLng.latitude, fromLatLng.longitude);
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
                      final latitude = snapshot.data!['latitude'] as double;
                      final longitude = snapshot.data!['longitude'] as double;

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
                        mapToolbarEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          setState(() {
                            mapController = controller;
                          });
                          _getPolyline(
                            PointLatLng(from.latitude, from.longitude),
                            PointLatLng(to.latitude, to.longitude),
                          );
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
                            markerId: const MarkerId('from'),
                            position: LatLng(
                              from.latitude,
                              from.longitude,
                            ),
                            infoWindow: InfoWindow(title: busLocation.name),
                          ),
                          Marker(
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                            markerId: const MarkerId('to'),
                            position: LatLng(
                              to.latitude,
                              to.longitude,
                            ),
                            infoWindow: InfoWindow(title: busLocation.name),
                          ),
                          Marker(
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                            markerId: MarkerId(busLocation.id),
                            position: LatLng(
                              busLocation.latitude,
                              busLocation.longitude,
                            ),
                            infoWindow: InfoWindow(title: busLocation.name),
                          ),
                        },
                        polylines: Set<Polyline>.of(polylines.values),
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
                    child:
                        Text('Bus not added yet!, Please add one to continue.'),
                  ),
                );
              }
            },
          ),
        ),
        floatingActionButton:
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('buses')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    return Column(
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
                            Get.toNamed(AppRoutes.busDetailScreen);
                          },
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.directions_bus_rounded),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const LocationStreamButton(),
                      ],
                    );
                  } else {
                    return FloatingActionButton(
                      onPressed: () => addBusDetails(size),
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.add),
                    );
                  }
                }),
      ),
    );
  }

  void addBusDetails(size) {
    final controller = Get.put(DriverHomeController());
    Get.bottomSheet(
      Form(
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
                DropdownButtonFormField<String>(
                  value: controller.fromController,
                  onChanged: (value) {
                    setState(() {
                      controller.fromController = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an starting stop';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'From',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.arrow_circle_up),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '6.9336339,79.8526605',
                      child: Text('Colombo'),
                    ),
                    DropdownMenuItem(
                      value: '7.0923857,79.9891625',
                      child: Text('Gampaha'),
                    ),
                    DropdownMenuItem(
                      value: '6.7744328,79.8801515',
                      child: Text('Morattuwa'),
                    ),
                    DropdownMenuItem(
                      value: '6.9346378,79.9814374',
                      child: Text('Kaduwella'),
                    ),
                    DropdownMenuItem(
                      value: '6.9111207,79.7049656',
                      child: Text('Kollupitiya'),
                    ),
                    DropdownMenuItem(
                      value: '6.0329092,80.2131825',
                      child: Text('Galle'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: controller.toController,
                  onChanged: (value) {
                    setState(() {
                      controller.toController = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an destination stop';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'To',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.arrow_circle_down),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '6.0329092,80.2131825',
                      child: Text('Galle'),
                    ),
                    DropdownMenuItem(
                      value: '6.9111207,79.7049656',
                      child: Text('Kollupitiya'),
                    ),
                    DropdownMenuItem(
                      value: '6.9346378,79.9814374',
                      child: Text('Kaduwella'),
                    ),
                    DropdownMenuItem(
                      value: '6.7744328,79.8801515',
                      child: Text('Morattuwa'),
                    ),
                    DropdownMenuItem(
                      value: '7.0923857,79.9891625',
                      child: Text('Gampaha'),
                    ),
                    DropdownMenuItem(
                      value: '6.9336339,79.8526605',
                      child: Text('Colombo'),
                    ),
                  ],
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
    );
  }
}
