import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../model/reminders.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';

class ManageRemindersScreen extends StatefulWidget {
  final VoidCallback onReminderSaved;

  const ManageRemindersScreen({
    super.key,
    required this.onReminderSaved,
  });
  @override
  _ManageRemindersScreenState createState() => _ManageRemindersScreenState();
}

class _ManageRemindersScreenState extends State<ManageRemindersScreen> {
  List<Reminder> reminders = [];

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  fetchReminders() async {
    reminders = await ReminderDatabase().getReminders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: reminders.isEmpty
            ? Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Text(
                    languageProvider.translate('manage_reminders.no_reminders'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  );
                },
              )
            : Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Text(languageProvider
                      .translate('manage_reminders.title_with_count')
                      .replaceAll('{count}', '${reminders.length}'));
                },
              ),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: reminders.isEmpty
          ? Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF6B46C1),
                      width: 4,
                    ),
                  ),
                  elevation: 0,
                  shadowColor: const Color.fromRGBO(107, 70, 193, 0.1),
                  child: SizedBox(
                    height: 150,
                    child: Center(
                      child: Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
                          return Text(
                            languageProvider
                                .translate('manage_reminders.no_reminders'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                Reminder reminder = reminders[index];
                final medicineName = reminder.medicineName;
                String formattedStartDate =
                    DateFormat('yyyy/MM/dd').format(reminder.startDate);
                String formattedEndDate =
                    DateFormat('yyyy/MM/dd').format(reminder.endDate);
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF6B46C1), width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(107, 70, 193, 0.1),
                        blurRadius: 14,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: '$medicineName ',
                                style: const TextStyle(
                                  color: const Color(0xFF2D3748),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '($formattedStartDate - $formattedEndDate)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFF718096),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            _buildDetailRow('Intake Quantity:',
                                '${reminder.intakeQuantity} piece(s)'),
                            _buildDetailRow(
                                'Times:',
                                reminder.times
                                    .map((time) => time.format(context))
                                    .join(', ')),
                            _buildDetailRow('Frequency:',
                                getFrequencyText(reminder.selectedDays)),
                            _buildDetailRow(
                                'Message:',
                                reminder.reminderName.isEmpty
                                    ? 'It\'s time to take your medicament!'
                                    : reminder.reminderName),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.trash,
                            color: Color(0xFF6B46C1),
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: const Text(
                                    'Confirm Deletion',
                                    style: TextStyle(color: Color(0xFF2D3748)),
                                  ),
                                  content: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text:
                                              'Are you sure you want to delete the reminder for ',
                                          style: TextStyle(
                                              color: Color(0xFF718096)),
                                        ),
                                        TextSpan(
                                          text: medicineName,
                                          style: const TextStyle(
                                              color: const Color(0xFF2D3748),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const TextSpan(
                                          text: '?',
                                          style: TextStyle(
                                              color: Color(0xFF718096)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Color(0xFF718096),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                            color: Color(0xFF6B46C1),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        await ReminderDatabase()
                                            .deleteReminderByReminderId(
                                                reminder.id);
                                        setState(() {
                                          reminders.removeAt(index);
                                        });
                                        Navigator.of(context).pop();
                                        widget.onReminderSaved();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF718096),
              ),
            ),
            TextSpan(
              text: value,
              style:
                  const TextStyle(color: const Color(0xFF2D3748), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  static String _getDayName(int index) {
    switch (index) {
      case 0:
        return 'Sun';
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return '';
    }
  }

  String getFrequencyText(List<bool> selectedDays) {
    if (selectedDays.every((day) => day)) {
      return 'Everyday';
    } else {
      return selectedDays
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => _getDayName(entry.key))
          .join(', ');
    }
  }
}
