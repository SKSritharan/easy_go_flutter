import 'package:cloud_firestore/cloud_firestore.dart';

class BusLocationData {
  final String id;
  final String name;
  double latitude;
  double longitude;

  BusLocationData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  static BusLocationData fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return BusLocationData(
      id: snapshot.id,
      name: data['name'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }
}
