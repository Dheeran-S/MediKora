import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/model/booking_models.dart';
import 'package:app/services/booking_service.dart';
import 'package:app/screens/user_appointments_screen.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final BookingService _bookingService = BookingService();

  List<Hospital> _hospitals = [];
  List<Doctor> _doctors = [];
  List<Slot> _slots = [];

  Hospital? _selectedHospital;
  Doctor? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  Slot? _selectedSlot;

  bool _isLoadingHospitals = false;
  bool _isLoadingDoctors = false;
  bool _isLoadingSlots = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() => _isLoadingHospitals = true);
    _hospitals = await _bookingService.getHospitals();
    setState(() => _isLoadingHospitals = false);
  }

  Future<void> _loadDoctors(String hospitalId) async {
    setState(() {
      _isLoadingDoctors = true;
      _doctors = [];
      _selectedDoctor = null;
      _slots = [];
      _selectedSlot = null;
    });
    _doctors = await _bookingService.getDoctors(hospitalId);
    setState(() => _isLoadingDoctors = false);
  }

  Future<void> _loadSlots() async {
    if (_selectedDoctor == null) return;
    
    setState(() {
      _isLoadingSlots = true;
      _slots = [];
      _selectedSlot = null;
    });
    
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _slots = await _bookingService.getSlots(_selectedDoctor!.id, dateStr);
    
    setState(() => _isLoadingSlots = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B46C1),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B46C1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadSlots();
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book an appointment')),
      );
      return;
    }

    setState(() => _isBooking = true);

    final userName = user.displayName ?? 'Valued User';
    final userEmail = user.email ?? 'No Email';

    final success = await _bookingService.bookSlot(
      _selectedSlot!.id, 
      user.uid,
      userName,
      userEmail,
    );

    setState(() => _isBooking = false);

    if (success) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Appointment booked successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _loadSlots(); // Refresh slots
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to book appointment. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserAppointmentsScreen(),
                ),
              );
            },
            tooltip: 'My Appointments',
          ),
        ],
      ),
      body: _isLoadingHospitals
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B46C1)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('1. Select Hospital'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Hospital>(
                    value: _selectedHospital,
                    decoration: _inputDecoration('Choose Hospital'),
                    isExpanded: true,
                    items: _hospitals.map((hospital) {
                      return DropdownMenuItem(
                        value: hospital,
                        child: Text(hospital.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHospital = value;
                      });
                      if (value != null) {
                        _loadDoctors(value.id);
                      }
                    },
                  ),

                  if (_selectedHospital != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('2. Select Doctor'),
                    const SizedBox(height: 8),
                    if (_isLoadingDoctors)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<Doctor>(
                        value: _selectedDoctor,
                        decoration: _inputDecoration('Choose Doctor'),
                        isExpanded: true,
                        items: _doctors.map((doctor) {
                          return DropdownMenuItem(
                            value: doctor,
                            child: Text('${doctor.name} (${doctor.specialization})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDoctor = value;
                          });
                          if (value != null) {
                            _loadSlots();
                          }
                        },
                      ),
                  ],

                  if (_selectedDoctor != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('3. Select Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, color: Color(0xFF6B46C1)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('4. Available Slots'),
                    const SizedBox(height: 8),
                    if (_isLoadingSlots)
                      const Center(child: CircularProgressIndicator())
                    else if (_slots.isEmpty)
                      const Text('No slots available for this date.', style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _slots.map((slot) {
                          final isSelected = _selectedSlot == slot;
                          return ChoiceChip(
                            label: Text('${slot.startTime} - ${slot.endTime}'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSlot = selected ? slot : null;
                              });
                            },
                            selectedColor: const Color(0xFF6B46C1),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : Colors.grey.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                  ],

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedSlot != null && !_isBooking
                          ? _bookAppointment
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isBooking
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Book Appointment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF6B46C1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
