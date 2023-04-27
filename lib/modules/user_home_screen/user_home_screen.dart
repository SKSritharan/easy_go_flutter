import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/bus.dart';
import '../../routes/app_routes.dart';
import './controller/user_home_controller.dart';

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
                  markers: buses
                      .map(
                        (bus) => Marker(
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          ),
                          markerId: MarkerId(bus.id),
                          position: LatLng(bus.latitude, bus.longitude),
                          infoWindow: InfoWindow(title: bus.name),
                        ),
                      )
                      .toSet(),
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


// class _UserHomeScreenState extends State<UserHomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<UserHomeController>(
//       builder: (controller) => Scaffold(
//         appBar: AppBar(
//           title: const Text('EasyGo'),
//           actions: [
//             PopupMenuButton(
//               icon: const Icon(Icons.more_vert),
//               itemBuilder: (context) {
//                 return [
//                   const PopupMenuItem(
//                     value: 1,
//                     textStyle: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black,
//                     ),
//                     child: Text("Profile"),
//                   ),
//                   const PopupMenuItem(
//                     value: 2,
//                     textStyle: TextStyle(
//                       fontSize: 16,
//                       color: Colors.red,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     child: Text("Logout"),
//                   ),
//                 ];
//               },
//               onSelected: (value) {
//                 if (value == 1) {
//                     Get.toNamed(AppRoutes.userProfileScreen);
//                   } else if (value == 2) {
//                     FirebaseAuth.instance.signOut();
//                     Get.offAndToNamed(AppRoutes.signInScreen);
//                   }
//               },
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             TextButton(
//               onPressed: () {
//                 controller.getLocation();
//               },
//               child: const Text('Add my location'),
//             ),
//             TextButton(
//               onPressed: () {
//                 controller.listenLocation();
//               },
//               child: const Text('Enable live location'),
//             ),
//             TextButton(
//               onPressed: () {
//                 controller.stopListening();
//               },
//               child: const Text('Stop live location'),
//             ),
//             Expanded(
//                 child: StreamBuilder(
//               stream:
//                   FirebaseFirestore.instance.collection('location').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final locations = snapshot.data!.docs.map((doc) {
//                     final latitude = doc['latitude'] as double;
//                     final longitude = doc['longitude'] as double;
//                     return LatLng(latitude, longitude);
//                   }).toList();

//                   return GoogleMap(
//                     initialCameraPosition: const CameraPosition(
//                       target: LatLng(7.8731, 80.7718),
//                       zoom: 10,
//                     ),
//                     markers: locations
//                         .map(
//                           (location) => Marker(
//                             icon: BitmapDescriptor.defaultMarkerWithHue(
//                                 BitmapDescriptor.hueBlue),
//                             markerId: MarkerId(location.toString()),
//                             position: location,
//                           ),
//                         )
//                         .toSet(),
//                   );
//                 } else {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               },
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyMap extends StatefulWidget {
//   final String user_id;

//   const MyMap(this.user_id, {super.key});
//   @override
//   _MyMapState createState() => _MyMapState();
// }

// class _MyMapState extends State<MyMap> {
//   final loc.Location location = loc.Location();
//   late GoogleMapController _controller;
//   bool _added = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: StreamBuilder(
//       stream: FirebaseFirestore.instance.collection('location').snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (_added) {
//           mymap(snapshot);
//         }
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return GoogleMap(
//           mapType: MapType.normal,
//           markers: {
//             Marker(
//                 position: LatLng(
//                   snapshot.data!.docs.singleWhere(
//                       (element) => element.id == widget.user_id)['latitude'],
//                   snapshot.data!.docs.singleWhere(
//                       (element) => element.id == widget.user_id)['longitude'],
//                 ),
//                 markerId: const MarkerId('id'),
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                     BitmapDescriptor.hueMagenta)),
//           },
//           initialCameraPosition: CameraPosition(
//               target: LatLng(
//                 snapshot.data!.docs.singleWhere(
//                     (element) => element.id == widget.user_id)['latitude'],
//                 snapshot.data!.docs.singleWhere(
//                     (element) => element.id == widget.user_id)['longitude'],
//               ),
//               zoom: 14.47),
//           onMapCreated: (GoogleMapController controller) async {
//             setState(() {
//               _controller = controller;
//               _added = true;
//             });
//           },
//         );
//       },
//     ));
//   }

//   Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
//     await _controller.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(
//             snapshot.data!.docs.singleWhere(
//                 (element) => element.id == widget.user_id)['latitude'],
//             snapshot.data!.docs.singleWhere(
//                 (element) => element.id == widget.user_id)['longitude'],
//           ),
//           zoom: 14.47,
//         ),
//       ),
//     );
//   }
// }
