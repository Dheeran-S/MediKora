import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import '../model/reminders.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// NOTIFICATION SINGLE MEDICAMENT *


Future<void> notificationMedicineReminder({
  required String medicineName,
  required String reminderName,
  required TimeOfDay timeToTake,
}) async {
  final hour = timeToTake.hour.toString().padLeft(2, '0');
  final minute = timeToTake.minute.toString().padLeft(2, '0');

  final String title = 'Time to take $medicineName';
  final String body =
  reminderName.isNotEmpty
      ? reminderName
      : 'Scheduled at $hour:$minute';

  await showNotification(title, body);
}


/// NOTIFICATION HANDLER *
Future<void> showNotification(String notificationTitle, String notificationText) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'default_channel_id',
    'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: '@mipmap/launcher_icon',
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await FlutterLocalNotificationsPlugin().show(
    0,
    notificationTitle,
    notificationText,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

// Create a global map to store the timers
Map<String, Timer> timers = {};

Future<void> scheduleNotification(String cardId, String title, String body, DateTime scheduledDate) async {
  var timeDifference = scheduledDate.difference(DateTime.now());
  var milliseconds = timeDifference.inMilliseconds;

  if (milliseconds > 0) {
    Timer timer = Timer(Duration(milliseconds: milliseconds), () async {
      await showNotification(title, body);
      timers.remove(cardId); // Remove the timer from the map after it fires
    });

    // Store the timer in the map using the cardId as the key
    timers[cardId] = timer;
  }
}

void cancelTimer(String cardId) {
  Timer? timer = timers[cardId];
  if (timer != null) {
    timer.cancel();
    timers.remove(cardId);
  }
}

Future<void> cancelReminderCardsTimers(int reminderId) async {
  List<ReminderCard> reminderCards = await ReminderDatabase().getReminderCardsByReminderId(reminderId);

  for (ReminderCard reminderCard in reminderCards) {
    cancelTimer(reminderCard.cardId);
  }
}

Future<void> setTimersOnAppStart() async {
  // Fetch all reminders
  List<Reminder> reminders = await ReminderDatabase().getReminders();

  for (Reminder reminder in reminders) {
    List<ReminderCard> reminderCards =
    await ReminderDatabase().getReminderCardsByReminderId(reminder.id);

    for (ReminderCard reminderCard in reminderCards) {
      final DateTime reminderDateTime = DateTime(
        reminderCard.day.year,
        reminderCard.day.month,
        reminderCard.day.day,
        reminderCard.time.hour,
        reminderCard.time.minute,
      );

      // Schedule only future notifications
      if (reminderDateTime.isAfter(DateTime.now())) {
        final String message =
        reminder.reminderName.isEmpty
            ? 'It\'s time to take your medicine'
            : reminder.reminderName;

        scheduleNotification(
          reminderCard.cardId,
          reminder.medicineName,
          message,
          reminderDateTime,
        );
      }
    }
  }
}
