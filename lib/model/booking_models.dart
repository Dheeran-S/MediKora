import 'package:cloud_firestore/cloud_firestore.dart';

class Hospital {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String email;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
  });

  factory Hospital.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hospital(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String hospitalId;
  final String hospitalName;
  final int consultationDuration;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospitalId,
    required this.hospitalName,
    required this.consultationDuration,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      hospitalId: data['hospitalId'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      consultationDuration: data['consultationDuration'] ?? 15,
    );
  }
}

class Slot {
  final String id;
  final String doctorId;
  final String hospitalId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String? bookedByName;
  final String? bookedByEmail;

  Slot({
    required this.id,
    required this.doctorId,
    required this.hospitalId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.bookedByName,
    this.bookedByEmail,
  });

  factory Slot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Slot(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      hospitalId: data['hospitalId'] ?? '',
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'AVAILABLE',
      bookedByName: data['bookedByName'],
      bookedByEmail: data['bookedByEmail'],
    );
  }
}
