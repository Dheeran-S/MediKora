import 'dart:async';

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





