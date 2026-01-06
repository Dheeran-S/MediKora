import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/config/booking_config.dart';
import 'package:app/model/booking_models.dart';
import 'package:flutter/foundation.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  FirebaseApp? _bookingApp;
  FirebaseFirestore? _firestore;

  Future<void> initialize() async {
    if (_bookingApp == null) {
      try {
        _bookingApp = await Firebase.initializeApp(
          name: 'bookingApp',
          options: BookingConfig.options,
        );
        _firestore = FirebaseFirestore.instanceFor(app: _bookingApp!);
      } catch (e) {
        // If app is already initialized, retrieve it
        try {
          _bookingApp = Firebase.app('bookingApp');
          _firestore = FirebaseFirestore.instanceFor(app: _bookingApp!);
        } catch (e) {
          debugPrint('Error initializing booking app: $e');
          rethrow;
        }
      }
    }
  }

  Future<List<Hospital>> getHospitals() async {
    await initialize();
    try {
      final snapshot = await _firestore!.collection('hospitals').get();
      return snapshot.docs.map((doc) => Hospital.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching hospitals: $e');
      return [];
    }
  }

  Future<List<Doctor>> getDoctors(String hospitalId) async {
    await initialize();
    try {
      final snapshot = await _firestore!
          .collection('doctors')
          .where('hospitalId', isEqualTo: hospitalId)
          .get();
      return snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
      return [];
    }
  }

  Future<Doctor?> getDoctor(String doctorId) async {
    await initialize();
    try {
      final doc = await _firestore!.collection('doctors').doc(doctorId).get();
      if (doc.exists) {
        return Doctor.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching doctor: $e');
      return null;
    }
  }

  Future<List<Slot>> getSlots(String doctorId, String date) async {
    await initialize();
    try {
      final snapshot = await _firestore!
          .collection('slots')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: date)
          .where('status', isEqualTo: 'AVAILABLE')
          .get();
      
      // Sort locally since we might not have a composite index set up yet
      final slots = snapshot.docs.map((doc) => Slot.fromFirestore(doc)).toList();
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));
      return slots;
    } catch (e) {
      debugPrint('Error fetching slots: $e');
      return [];
    }
  }

  Future<bool> bookSlot(String slotId, String userId, String userName, String userEmail) async {
    await initialize();
    try {
      await _firestore!.collection('slots').doc(slotId).update({
        'status': 'BOOKED',
        'bookedBy': userId,
        'bookedByName': userName,
        'bookedByEmail': userEmail,
        'bookedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error booking slot: $e');
      return false;
    }
  }

  Future<List<Slot>> getUserAppointments(String userId) async {
    await initialize();
    try {
      final snapshot = await _firestore!
          .collection('slots')
          .where('bookedBy', isEqualTo: userId)
          .where('status', isEqualTo: 'BOOKED')
          .get();
      
      final slots = snapshot.docs.map((doc) => Slot.fromFirestore(doc)).toList();
      // Sort by date/time
      slots.sort((a, b) {
        int dateComp = a.date.compareTo(b.date);
        if (dateComp != 0) return dateComp;
        return a.startTime.compareTo(b.startTime);
      });
      return slots;
    } catch (e) {
      debugPrint('Error fetching user appointments: $e');
      return [];
    }
  }
}
