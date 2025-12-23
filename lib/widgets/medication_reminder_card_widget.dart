import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/model/reminders.dart';

class MedicationReminderCard extends StatefulWidget {
  final Function(ReminderCard) onCardUpdated;
  final String cardId;
  final int reminderId;
  final String medicineName;
  final DateTime day;
  final TimeOfDay time;
  final int intakeQuantity;
  final bool isTaken;
  final bool isJumped;
  final TimeOfDay? pressedTime;

  const MedicationReminderCard({
    super.key,
    required this.onCardUpdated,
    required this.cardId,
    required this.reminderId,
    required this.medicineName,
    required this.day,
    required this.time,
    required this.intakeQuantity,
    required this.isTaken,
    required this.isJumped,
    required this.pressedTime,
  });

  @override
  MedicationReminderCardState createState() => MedicationReminderCardState();
}

class MedicationReminderCardState extends State<MedicationReminderCard> {
  late bool isTaken;
  late bool isJumped;
  late TimeOfDay? pressedTime;
  late bool isTakeButton;
  late bool isNotToday;

  @override
  void initState() {
    super.initState();
    isTaken = widget.isTaken;
    isJumped = widget.isJumped;
    pressedTime = widget.pressedTime;
    isNotToday = widget.day.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    isNotToday = widget.day.isAfter(DateTime.now());
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: GestureDetector(
          onTap: () {
            _showActionBottomSheet(context);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isTaken || isJumped
                    ? const Color(0xFF6B46C1)
                    : const Color(0xFF6B46C1),
                width: 4,
              ),
            ),
            elevation: 0,
            shadowColor: Color.fromRGBO(107, 70, 193, 0.1),
            color: isTaken ? const Color(0xFF6B46C1) : Colors.white,
            child: SizedBox(
              height: 150,
              child: Stack(
                children: [
                  // Specifics of medication
                  Stack(
                    children: [
                      // Three dots icon
                      Positioned(
                        top: 20,
                        right: 18,
                        child: Icon(
                          FontAwesomeIcons.ellipsisVertical,
                          size: 15,
                          color: isNotToday
                              ? const Color(0xFF718096)
                              : isTaken
                                  ? Colors.white
                                  : const Color(0xFF6B46C1),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    FontAwesomeIcons.solidClock,
                                    size: 15,
                                    color: isNotToday
                                        ? const Color(0xFF718096)
                                        : isTaken
                                            ? Colors.white
                                            : const Color(0xFF6B46C1),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.time.format(context),
                                  style: TextStyle(
                                    fontFamily: 'Open_Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isNotToday
                                        ? const Color(0xFF718096)
                                        : isTaken
                                            ? Colors.white
                                            : const Color(0xFF6B46C1),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              widget.medicineName,
                              style: TextStyle(
                                fontFamily: 'Open_Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isNotToday
                                    ? const Color(0xFF718096)
                                    : isTaken
                                        ? Colors.white
                                        : const Color(0xFF2D3748),
                              ),
                            ),
                            if (isTaken) ...[
                              const Text(
                                'Taken',
                                style: TextStyle(
                                  fontFamily: 'Open_Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ] else if (isNotToday) ...[
                              const Text(
                                'Scheduled',
                                style: TextStyle(
                                  fontFamily: 'Open_Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ] else if (!isTaken && !isJumped) ...[
                              Text(
                                '${widget.intakeQuantity} piece(s)',
                                style: TextStyle(
                                  fontFamily: 'Open_Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B46C1),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // White tick after taken
                      if (isTaken) ...[
                        const Positioned(
                          top: -5,
                          right: -25,
                          child: Icon(
                            FontAwesomeIcons.check,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Take button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isJumped || isTaken || isNotToday) {
                            _showActionBottomSheet(context);
                          } else {
                            isTakeButton = true;
                            _takeMedicament(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          backgroundColor: isNotToday
                              ? const Color(0xFFE9D8FD)
                              : const Color(0xFF6B46C1),
                          foregroundColor: isNotToday
                              ? const Color(0xFF6B46C1)
                              : Colors.white,
                        ),
                        child: Text(
                          isTaken
                              ? '${pressedTime!.hour.toString().padLeft(2, '0')}:${pressedTime!.minute.toString().padLeft(2, '0')}'
                              : isJumped
                                  ? 'Skipped'
                                  : 'Take',
                          style: const TextStyle(
                            fontFamily: 'Open_Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: const Color(0xFF6B46C1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        FontAwesomeIcons.solidClock,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.time.format(context),
                      style: const TextStyle(
                        fontFamily: 'Open_Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.medicineName,
                  style: const TextStyle(
                    fontFamily: 'Open_Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                if (isNotToday) ...[
                  const Text(
                    'Scheduled',
                    style: TextStyle(
                      fontFamily: 'Open_Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  Row(
                    children: isJumped
                        ? [
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  _unSkipMedicamentIntake(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE9D8FD),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.rotateLeft,
                                        color: Color(0xFF6B46C1)),
                                    SizedBox(width: 5),
                                    Text(
                                      'Un-Skip',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6B46C1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isTaken) {
                                    _changeIntakeTime(context);
                                  } else {
                                    _skipMedicamentIntake(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE9D8FD),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  isTaken ? 'Time' : 'Skip',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B46C1),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isTaken) {
                                    _unTakeMedicament(context);
                                  } else {
                                    isTakeButton = false;
                                    _takeMedicament(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B46C1),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        isTaken
                                            ? FontAwesomeIcons.rotateLeft
                                            : FontAwesomeIcons.check,
                                        color: const Color(0xFFE9D8FD)),
                                    const SizedBox(width: 5),
                                    Text(
                                      isTaken ? 'Un-Take' : 'Take',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFE9D8FD),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  void showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: const Color(0xFF6B46C1),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _takeMedicament(BuildContext context) async {
    TimeOfDay now = TimeOfDay.now();

    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: true,
      isJumped: false,
      pressedTime: now,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isTaken = true;
      isJumped = false;
      pressedTime = now;
    });

    widget.onCardUpdated(updatedCard);

    if (!isTakeButton) {
      Navigator.pop(context);
    }
  }

  Future<void> _unTakeMedicament(BuildContext context) async {
    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: false,
      isJumped: false,
      pressedTime: null,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isTaken = false;
      isJumped = false;
      pressedTime = null;
    });

    widget.onCardUpdated(updatedCard);

    Navigator.pop(context);
  }

  Future<void> _skipMedicamentIntake(BuildContext context) async {
    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: false,
      isJumped: true,
      pressedTime: null,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isJumped = true;
      isTaken = false;
      pressedTime = null;
    });

    Navigator.pop(context);
  }

  Future<void> _unSkipMedicamentIntake(BuildContext context) async {
    final updatedCard = ReminderCard(
      cardId: widget.cardId,
      reminderId: widget.reminderId,
      day: widget.day,
      time: widget.time,
      intakeQuantity: widget.intakeQuantity,
      isTaken: false,
      isJumped: false,
      pressedTime: null,
    );

    await ReminderDatabase().updateReminderCard(updatedCard);

    setState(() {
      isTaken = false;
      isJumped = false;
      pressedTime = null;
    });

    Navigator.pop(context);
  }

  Future<void> _changeIntakeTime(BuildContext context) async {
    TimeOfDay pickedTime = TimeOfDay.now();

    final TimeOfDay? newPickedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                children: [
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: DateTime(
                          2024, 1, 1, pickedTime.hour, pickedTime.minute),
                      onDateTimeChanged: (DateTime newDateTime) {
                        setState(() {
                          pickedTime = TimeOfDay.fromDateTime(newDateTime);
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  CupertinoButton(
                    child: Text(
                      '${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: const Color(0xFF6B46C1),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, pickedTime);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (newPickedTime != null) {
      final updatedCard = ReminderCard(
        cardId: widget.cardId,
        reminderId: widget.reminderId,
        day: widget.day,
        time: widget.time,
        intakeQuantity: widget.intakeQuantity,
        isTaken: true,
        isJumped: false,
        pressedTime: newPickedTime,
      );

      await ReminderDatabase().updateReminderCard(updatedCard);

      setState(() {
        isTaken = true;
        isJumped = false;
        pressedTime = newPickedTime;
      });

      widget.onCardUpdated(updatedCard);

      Navigator.pop(context);
    }
  }
}
