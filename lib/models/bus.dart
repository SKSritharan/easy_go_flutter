import 'package:cloud_firestore/cloud_firestore.dart';

class Bus {
  final String id;
  final String name;
  double latitude;
  double longitude;

  Bus({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  static Bus fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Bus(
      id: snapshot.id,
      name: data['name'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }
}
