import 'package:flutter/material.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: const Color(0xFF6B46C1),
      ),
      body: const Center(
        child: Text(
          'Appointment scheduling coming soon',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
