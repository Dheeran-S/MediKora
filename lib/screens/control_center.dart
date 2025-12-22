import 'package:flutter/material.dart';
import 'package:app/screens/add_reminder_screen.dart';
import 'package:app/screens/settings_screen.dart';
import 'package:app/screens/scan_prescription.dart';
import 'manage_reminders_screen.dart';
import 'package:app/model/reminders.dart';

Future<void> _saveScannedReminders(
    List<Map<String, dynamic>> scannedReminders) async {

  final reminderDb = ReminderDatabase();

  for (final data in scannedReminders) {
    final reminderId = DateTime.now().millisecondsSinceEpoch;

    final reminder = Reminder(
      id: reminderId,
      reminderName: data['reminderName'],
      medicineName: data['reminderName'], // key point
      selectedDays: List<bool>.from(data['selectedDays']),
      startDate: data['startDate'],
      endDate: data['endDate'],
      intakeQuantity: data['intakeQuantity'],
      times: List<TimeOfDay>.from(data['times']),
    );

    // 1️⃣ Save reminder
    await reminderDb.insertReminder(reminder);

    // 2️⃣ Generate reminder cards + notifications
    await reminderDb.updateReminderCards(reminder);
  }

  // 3️⃣ Refresh UI so reminders appear
   setState(() {});
}


void showControlCenter(BuildContext context, VoidCallback onReminderSaved, Future<List<Medicament>> medicamentList, VoidCallback onMedicamentListUpdated) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 259,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
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
                        Navigator.of(context).pop(); // Close the bottom sheet

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
                        }


                        // If reminders data was returned, handle it
                        if (remindersData != null && remindersData is List<Map<String, dynamic>>) {
                          // You can either:
                          // 1. Save them directly to your database here
                          // 2. Pass them to AddReminderPage to review/edit
                          // 3. Show a confirmation dialog

                          // Option 2 - Navigate to AddReminderPage with the data
                          // (You'll need to modify AddReminderPage to accept this data)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReminderPage(
                                onReminderSaved: onReminderSaved,
                                medicamentList: medicamentList,
                                onMedicamentListUpdated: onMedicamentListUpdated,
                                isEditing: false,
                                // prescriptionReminders: remindersData, // Pass the data
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(225, 95, 0, 1),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      icon: Image.asset(
                        'assets/icons/alarm_icon.png',
                        width: 17,
                      ),
                      label: const Text("Scan Prescription"), // Changed label
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
                              medicamentList: medicamentList,
                              onMedicamentListUpdated: onMedicamentListUpdated,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromRGBO(199, 84, 0, 1),
                        backgroundColor: const Color.fromRGBO(255, 198, 157, 1),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      icon: Image.asset(
                        'assets/icons/calendar_icon.png',
                        width: 17,
                      ),
                      label: const Text("Manage reminders"),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromRGBO(199, 84, 0, 1),
                        backgroundColor: const Color.fromRGBO(255, 198, 157, 1),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      icon: const Icon(
                        Icons.settings,
                        size: 17,
                      ),
                      label: const Text("Settings"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 242,
            left: (MediaQuery.of(context).size.width - 120) / 2,
            child:
            Image.asset(
              'assets/icons/pingu-transparent-shadow.png',
              width: 120,
              height: 120,
            ),
          ),
        ],
      );
    },
  );
}