import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Bus {
  final String id;
  final String name;
  final String number;
  LatLng from;
  LatLng to;

  Bus({
    required this.id,
    required this.name,
    required this.number,
    required this.from,
    required this.to,
  });

  static Bus fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Bus(
      id: snapshot.id,
      name: data['name'],
      number: data['number'],
      from: LatLng(data['from']['latitude'], data['from']),
      to: LatLng(data['to']['latitude'], data['to']),
    );
  }
}
