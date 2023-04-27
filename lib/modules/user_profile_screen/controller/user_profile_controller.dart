import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>> getProfileData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection('users').doc(user!.uid).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Document does not exist');
    }
  }
}
