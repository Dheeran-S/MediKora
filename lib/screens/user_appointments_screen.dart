import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/model/booking_models.dart';
import 'package:app/services/booking_service.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final slots = await _bookingService.getUserAppointments(user.uid);
      
      // Fetch details for each slot
      final List<Map<String, dynamic>> loadedAppointments = [];
      for (var slot in slots) {
        final doctor = await _bookingService.getDoctor(slot.doctorId);
        if (doctor != null) {
          loadedAppointments.add({
            'slot': slot,
            'doctor': doctor,
          });
        }
      }
      
      if (mounted) {
        setState(() {
          _appointments = loadedAppointments;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B46C1)))
          : _appointments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No appointments found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final item = _appointments[index];
                    final Slot slot = item['slot'];
                    final Doctor doctor = item['doctor'];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFE9D8FD),
                                  child: Text(
                                    doctor.name.isNotEmpty ? doctor.name[0] : 'Dr',
                                    style: const TextStyle(color: Color(0xFF6B46C1)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        doctor.specialization,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        doctor.hospitalName,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    'CONFIRMED',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  slot.date,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 24),
                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  '${slot.startTime} - ${slot.endTime}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
