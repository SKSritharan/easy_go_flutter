import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class UserHomeController extends GetxController {

  
  // final loc.Location location = loc.Location();
  // StreamSubscription<loc.LocationData>? locationSubscription;

  // @override
  // void onClose() {
  //   locationSubscription?.cancel();
  //   super.onClose();
  // }

  // getLocation() async {
  //   try {
  //     final loc.LocationData locationResult = await location.getLocation();
  //     await FirebaseFirestore.instance.collection('location').doc('user1').set({
  //       'latitude': locationResult.latitude,
  //       'longitude': locationResult.longitude,
  //       'name': 'john'
  //     }, SetOptions(merge: true));
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<void> listenLocation() async {
  //   locationSubscription = location.onLocationChanged.handleError((onError) {
  //     print(onError);
  //     locationSubscription?.cancel();
  //     locationSubscription = null;
  //   }).listen((loc.LocationData currentlocation) async {
  //     await FirebaseFirestore.instance.collection('location').doc('user1').set({
  //       'latitude': currentlocation.latitude,
  //       'longitude': currentlocation.longitude,
  //       'name': 'john'
  //     }, SetOptions(merge: true));
  //   });
  // }

  // stopListening() {
  //   locationSubscription?.cancel();
  //   locationSubscription = null;
  // }

  // requestPermission() async {
  //   var status = await Permission.location.request();
  //   if (status.isGranted) {
  //     print('done');
  //   } else if (status.isDenied) {
  //     requestPermission();
  //   } else if (status.isPermanentlyDenied) {
  //     openAppSettings();
  //   }
  // }
}
