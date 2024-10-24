import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shelter_partner/models/device_settings.dart';

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String type;
  final String shelterId;
  final DeviceSettings deviceSettings;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.type,
    required this.shelterId,
    required this.deviceSettings,
  });

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      type: data['type'],
      shelterId: data['shelterID'],
      deviceSettings: DeviceSettings.fromMap(data['deviceSettings'] ?? {}),
    );
  }

  AppUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? type,
    String? shelterId,
    DeviceSettings? deviceSettings,
  }) {
    return AppUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      type: type ?? this.type,
      shelterId: shelterId ?? this.shelterId,
      deviceSettings: deviceSettings ?? this.deviceSettings,
    );
  }
}
