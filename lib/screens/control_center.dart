import 'package:flutter/material.dart';
import 'package:app/screens/scan_prescription.dart';
import 'manage_reminders_screen.dart';
import 'package:app/model/reminders.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';

Future<void> _saveScannedReminders(
    List<Map<String, dynamic>> scannedReminders) async {
  final reminderDb = ReminderDatabase();
  final existing = await reminderDb.getReminders();
  int nextId = existing.isEmpty ? 1 : existing.last.id + 1;

  for (final data in scannedReminders) {
    final reminder = Reminder(
      id: nextId++,
      reminderName: data['reminderName'] ?? '',
      medicineName: data['reminderName'] ?? '',
      selectedDays: List<bool>.from(data['selectedDays']),
      startDate: data['startDate'],
      endDate: data['endDate'],
      intakeQuantity: data['intakeQuantity'],
      times: List<TimeOfDay>.from(data['times']),
    );

    // 1️⃣ Insert reminder and get real DB ID
    final int newId = await reminderDb.insertReminder(reminder);

    // 2️⃣ Create reminder with correct ID
    final savedReminder = Reminder(
      id: newId,
      reminderName: reminder.reminderName,
      medicineName: reminder.medicineName,
      selectedDays: reminder.selectedDays,
      startDate: reminder.startDate,
      endDate: reminder.endDate,
      intakeQuantity: reminder.intakeQuantity,
      times: reminder.times,
    );

    // 3️⃣ Generate reminder cards + notifications
    await reminderDb.updateReminderCards(savedReminder);
  }
}

void showControlCenter(BuildContext context, VoidCallback onReminderSaved) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 259,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 50),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(context).pop(); // Close bottom sheet

                            // Navigate to scan prescription and wait for result
                            final remindersData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScanPrescription(),
                              ),
                            );

                            if (remindersData != null &&
                                remindersData is List<Map<String, dynamic>>) {
                              await _saveScannedReminders(remindersData);
                              onReminderSaved(); // refresh HomeScreen
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF6B46C1),
                            elevation: 0,
                            shadowColor: Color.fromRGBO(107, 70, 193, 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Image.asset(
                            'assets/icons/alarm_icon.png',
                            width: 17,
                          ),
                          label: Text(languageProvider
                              .translate('control_center.scan_prescription')),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageRemindersScreen(
                                  onReminderSaved: onReminderSaved,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF6B46C1),
                            backgroundColor: const Color(0xFFE9D8FD),
                            elevation: 0,
                            shadowColor: Color.fromRGBO(107, 70, 193, 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Image.asset(
                            'assets/icons/calendar_icon.png',
                            width: 17,
                          ),
                          label: Text(languageProvider
                              .translate('control_center.manage_reminders')),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 230,
                left: (MediaQuery.of(context).size.width - 120) / 2,
                child: Image.asset(
                  'assets/icons/kora-transparent1.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
