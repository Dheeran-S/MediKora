import 'dart:async';
import 'package:app/model/medicaments.dart';
import 'package:app/database/local_medicament_stock.dart';
import 'package:app/notifications/system_notification.dart';

/** DAILY CHECKER **/
DateTime _lastCalledDay = DateTime.now();

void checkDayChangeInit() {
  checkDayChange();
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day + 1);
  final durationUntilMidnight = midnight.difference(now);

  Timer(durationUntilMidnight, () {
    checkDayChangeInit();
  });
}

void checkDayChange() {
  final now = DateTime.now();
  if (_lastCalledDay.day != now.day) {
    _lastCalledDay = now;
  }
}





