import 'package:flutter/material.dart';
import 'package:app/model/reminders.dart';
import 'package:app/widgets/calendar_widget.dart';
import 'package:app/widgets/medication_reminder_card_widget.dart';
import 'package:app/widgets/elipse_background.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';

late Future<List<Reminder>> _remindersFuture;

class HomeScreen extends StatefulWidget {
  final VoidCallback onReminderSaved;

  const HomeScreen({super.key, required this.onReminderSaved});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _remindersFuture = getReminders();
  }

  void _handleDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  Future<List<Reminder>> getReminders() async {
    return await ReminderDatabase().getReminders();
  }

  void refreshReminderList() async {
    setState(() {
      _remindersFuture = getReminders();
      _buildMedicationReminderWidget();
    });
  }

  @override
  Widget build(BuildContext context) {
    refreshReminderList();
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Stack(
        children: [
          const ElipseBackground(),
          CalendarWidget(
            onDaySelected: _handleDaySelected,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 230,
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: SingleChildScrollView(
              child: _buildMedicationReminderWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationReminderWidget() {
    return FutureBuilder<void>(
      // Delay used to fix small visual bug
      future: Future.delayed(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          return _buildReminderList();
        }
      },
    );
  }

  Widget _buildReminderList() {
    return FutureBuilder<List<Reminder>>(
      future: _remindersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          List<Reminder>? reminders = snapshot.data;
          if (reminders != null && reminders.isNotEmpty) {
            return FutureBuilder<List<ReminderWithCards>>(
              future: _getApplicableReminders(reminders),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else {
                  List<ReminderWithCards>? applicableReminders = snapshot.data;
                  if (applicableReminders != null &&
                      applicableReminders.isNotEmpty) {
                    return _buildReminderCardInfoList(applicableReminders);
                  }
                }
                return noRemindersCard();
              },
            );
          } else {
            return noRemindersCard();
          }
        }
      },
    );
  }

  Future<List<ReminderWithCards>> _getApplicableReminders(
      List<Reminder> reminders) async {
    List<ReminderWithCards> applicableReminders = [];

    for (Reminder reminder in reminders) {
      List<ReminderCard> reminderCards = await ReminderDatabase()
          .getReminderCardsForSelectedDay(reminder.id, _selectedDay);
      if (reminderCards.isNotEmpty) {
        applicableReminders.add(ReminderWithCards(reminder, reminderCards));
      }
    }

    return applicableReminders;
  }

  Widget _buildReminderCardInfoList(
      List<ReminderWithCards> applicableReminders) {
    return FutureBuilder<List<_ReminderCardInfo>>(
      future: _getReminderCardInfos(applicableReminders),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          List<_ReminderCardInfo> reminderCardInfos = snapshot.data!;
          reminderCardInfos.sort((a, b) =>
              _compareTimeOfDay(a.reminderCard.time, b.reminderCard.time));

          return _buildReminderCardsColumn(reminderCardInfos);
        }
      },
    );
  }

  Widget _buildReminderCardsColumn(List<_ReminderCardInfo> reminderCardInfos) {
    return Column(
      children: [
        ...reminderCardInfos.map((info) {
          return MedicationReminderCard(
            onCardUpdated: (updatedCard) {
              int index = reminderCardInfos.indexWhere(
                (info) => info.reminderCard.cardId == updatedCard.cardId,
              );

              if (index != -1) {
                reminderCardInfos[index] = _ReminderCardInfo(
                    updatedCard, reminderCardInfos[index].reminder);

                // setState(() {
                //   _remindersFuture = getReminders();
                // });
              }
            },
            cardId: info.reminderCard.cardId,
            reminderId: info.reminderCard.reminderId,
            medicineName: info.reminder.medicineName,
            day: info.reminderCard.day,
            time: info.reminderCard.time,
            intakeQuantity: info.reminderCard.intakeQuantity,
            isTaken: info.reminderCard.isTaken,
            isJumped: info.reminderCard.isJumped,
            pressedTime: info.reminderCard.pressedTime,
          );
        }),
        const SizedBox(height: 150),
      ],
    );
  }

  Future<List<_ReminderCardInfo>> _getReminderCardInfos(
      List<ReminderWithCards> reminderWithCardsList) async {
    List<_ReminderCardInfo> reminderCardInfos = [];

    for (var reminderWithCards in reminderWithCardsList) {
      for (var reminderCard in reminderWithCards.reminderCards) {
        reminderCardInfos.add(
          _ReminderCardInfo(reminderCard, reminderWithCards.reminder),
        );
      }
    }
    return reminderCardInfos;
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    int hourComparison = a.hour.compareTo(b.hour);
    if (hourComparison != 0) {
      return hourComparison;
    } else {
      return a.minute.compareTo(b.minute);
    }
  }

  Widget noRemindersCard() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Center(
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
              shadowColor: Color.fromRGBO(107, 70, 193, 0.1),
              child: SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    languageProvider.translate('home.no_reminders'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReminderWithCards {
  final Reminder reminder;
  final List<ReminderCard> reminderCards;

  ReminderWithCards(this.reminder, this.reminderCards);
}

class _ReminderCardInfo {
  final ReminderCard reminderCard;
  final Reminder reminder;

  _ReminderCardInfo(this.reminderCard, this.reminder);
}
