import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ScanPrescription extends StatefulWidget {
  const ScanPrescription({Key? key}) : super(key: key);

  @override
  State<ScanPrescription> createState() => _ScanPrescriptionState();
}

class _ScanPrescriptionState extends State<ScanPrescription> {
  // Replace with your Gemini API key
  static const String GEMINI_API_KEY = 'AIzaSyAh8eU8AW-NWuGSKs582Fvgb_m6lhLxp30';
  static const String GEMINI_API_URL =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // State variables
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _prescriptionData;
  List<Map<String, dynamic>>? _remindersData;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _image = File(photo.path);
          _error = null;
          _prescriptionData = null;
          _remindersData = null;
        });
        await _sendToGemini();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to capture image: $e';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _image = File(photo.path);
          _error = null;
          _prescriptionData = null;
          _remindersData = null;
        });
        await _sendToGemini();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _sendToGemini() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Convert image to base64
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare the request
      final response = await http.post(
        Uri.parse('$GEMINI_API_URL?key=$GEMINI_API_KEY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Analyze this handwritten doctor prescription and extract the following information in JSON format:
{
  "patientName": "patient name if visible",
  "doctorName": "doctor name if visible",
  "date": "prescription date if visible (YYYY-MM-DD format)",
  "medications": [
    {
      "name": "medication name",
      "dosage": "dosage amount (e.g., 500mg, 10ml)",
      "frequency": "frequency description (e.g., twice daily, every 8 hours, morning and evening)",
      "timesPerDay": number of times per day as integer,
      "duration": "duration in days as integer only (e.g., 7, 14, 30)",
      "instructions": "any special instructions for this medication"
    }
  ],
  "diagnosis": "diagnosis or condition if mentioned",
  "notes": "any additional notes"
}

IMPORTANT: 
- For frequency, extract how many times per day the medication should be taken
- For duration, extract only the number of days as an integer
- If morning/evening is mentioned, set timesPerDay to 2
- If thrice daily or three times, set timesPerDay to 3
- Only return valid JSON. If any field is not visible or unclear, use null or 0 for numbers.'''
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        //temp
        print('🟡 Gemini raw body: ${response.body}');
        //temp

        // Extract JSON from the response
        String jsonText = text.trim();
        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        }
        if (jsonText.startsWith('```')) {
          jsonText = jsonText.substring(3);
        }
        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }

        final prescriptionData = jsonDecode(jsonText.trim());

        // Convert to reminders format
        final reminders = _convertToReminders(prescriptionData);

        setState(() {
          _prescriptionData = prescriptionData;
          _remindersData = reminders;
          _isLoading = false;
        });
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to analyze prescription: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _convertToReminders(Map<String, dynamic> prescription) {
    List<Map<String, dynamic>> reminders = [];

    if (prescription['medications'] == null) return reminders;

    final medications = prescription['medications'] as List;
    final now = DateTime.now();

    for (int i = 0; i < medications.length; i++) {
      final med = medications[i];
      final timesPerDay = med['timesPerDay'] ?? 1;
      final durationDays = _parseDuration(med['duration']);

      // Generate times based on frequency
      List<TimeOfDay> times = _generateTimes(timesPerDay);

      reminders.add({
        'reminderName': med['name'] ?? 'Medication ${i + 1}',
        'medicamentId': i + 1,
        'intakeQuantity': 1,
        'dosage': med['dosage'],
        'instructions': med['instructions'],
        'startDate': now,
        'endDate': now.add(Duration(days: durationDays)),
        'times': times,
        'selectedDays': [true, true, true, true, true, true, true],
      });
    }

    return reminders;
  }

  int _parseDuration(dynamic duration) {
    if (duration == null) return 30;
    if (duration is int) return duration;

    String durationStr = duration.toString();
    final match = RegExp(r'\d+').firstMatch(durationStr);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 30;
    }

    return 30;
  }

  List<TimeOfDay> _generateTimes(int timesPerDay) {
    List<TimeOfDay> times = [];

    switch (timesPerDay) {
      case 1:
        times.add(const TimeOfDay(hour: 8, minute: 0));
        break;
      case 2:
        times.add(const TimeOfDay(hour: 8, minute: 0));
        times.add(const TimeOfDay(hour: 20, minute: 0));
        break;
      case 3:
        times.add(const TimeOfDay(hour: 8, minute: 0));
        times.add(const TimeOfDay(hour: 14, minute: 0));
        times.add(const TimeOfDay(hour: 20, minute: 0));
        break;
      case 4:
        times.add(const TimeOfDay(hour: 8, minute: 0));
        times.add(const TimeOfDay(hour: 12, minute: 0));
        times.add(const TimeOfDay(hour: 16, minute: 0));
        times.add(const TimeOfDay(hour: 20, minute: 0));
        break;
      default:
        times.add(const TimeOfDay(hour: 8, minute: 0));
    }

    return times;
  }

  void _useReminders() {
    if (_remindersData == null || _remindersData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reminders to save')),
      );
      return;
    }

    Navigator.pop(context, _remindersData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Prescription'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_remindersData != null && _remindersData!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _useReminders,
              tooltip: 'Use Reminders',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _captureImage,
                    icon: const Icon(Icons.camera),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Analyzing prescription...'),
                  ],
                ),
              ),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_prescriptionData != null) ...[
              const Text(
                'Prescription Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInfoCard('Patient Name', _prescriptionData!['patientName']),
              _buildInfoCard('Doctor Name', _prescriptionData!['doctorName']),
              _buildInfoCard('Date', _prescriptionData!['date']),
              _buildInfoCard('Diagnosis', _prescriptionData!['diagnosis']),
              const SizedBox(height: 20),
              const Text(
                'Medication Reminders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_remindersData != null && _remindersData!.isNotEmpty)
                ...(_remindersData!).map((reminder) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.medication, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reminder['reminderName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildReminderRow('Dosage', reminder['dosage'] ?? 'Not specified'),
                          _buildReminderRow('Quantity', '${reminder['intakeQuantity']} unit(s)'),
                          _buildReminderRow(
                            'Times',
                            (reminder['times'] as List<TimeOfDay>)
                                .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
                                .join(', '),
                          ),
                          _buildReminderRow(
                            'Duration',
                            '${reminder['startDate'].toString().split(' ')[0]} to ${reminder['endDate'].toString().split(' ')[0]}',
                          ),
                          if (reminder['instructions'] != null)
                            _buildReminderRow('Instructions', reminder['instructions']),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _useReminders,
                icon: const Icon(Icons.alarm_add),
                label: const Text('Create Reminders'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}