import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDaySelected;

  const CalendarWidget({super.key, required this.onDaySelected});

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  late int initialPage;
  late PageController pageController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

    initialPage =
        selectedDate.difference(DateTime(DateTime.now().year, 1, 1)).inDays;

    pageController =
        PageController(initialPage: initialPage, viewportFraction: 0.14);

    pageController.addListener(() {
      final newPageIndex = pageController.page!.round();
      final newSelectedDate = DateTime(
        DateTime.now().year,
        1,
        1,
      ).add(Duration(days: newPageIndex));

      if (newSelectedDate != selectedDate) {
        setState(() {
          selectedDate = newSelectedDate;
          widget.onDaySelected(selectedDate);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfYear = DateTime(today.year, 1, 1);
    final daysUntilToday = today.difference(startOfYear).inDays;
    final daysToShow = daysUntilToday + 15;

    return Stack(
      children: [
        // 🔹 CENTERED TODAY / DATE TEXT
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Text(
                  getSelectedDay(selectedDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  getSelectedDayDescription(selectedDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE9D8FD),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🔹 CENTER HIGHLIGHT BOX
        Positioned(
          left: (MediaQuery.of(context).size.width - 58) / 2,
          top: 140,
          child: Container(
            width: 60,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // 🔹 CALENDAR SCROLLER
        Positioned(
          left: 0,
          right: 0,
          top: 125,
          child: SizedBox(
            height: 100,
            child: PageView.builder(
              itemCount: daysToShow,
              controller: pageController,
              itemBuilder: (context, index) {
                final date = DateTime.now()
                    .subtract(Duration(days: initialPage - index));

                return GestureDetector(
                  onTap: () => scrollToDate(date),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getDayOfWeek(date.weekday),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE9D8FD),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: date.isAfter(DateTime.now())
                              ? const Color(0xFFE9D8FD)
                              : Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: date.isAfter(DateTime.now())
                                ? const Color(0xFF718096)
                                : const Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void scrollToDate(DateTime date) {
    final pageIndex = date.difference(DateTime(date.year, 1, 1)).inDays;
    pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  String getDayOfWeek(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  String getDayOfWeekComplete(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  String getMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String getSelectedDay(DateTime d) {
    final today = DateTime.now();

    if (DateUtils.isSameDay(d, today)) return 'Today';
    if (DateUtils.isSameDay(d, today.add(const Duration(days: 1))))
      return 'Tomorrow';
    if (DateUtils.isSameDay(d, today.subtract(const Duration(days: 1))))
      return 'Yesterday';

    return getDayOfWeekComplete(d.weekday);
  }

  String getSelectedDayDescription(DateTime d) {
    return '${getDayOfWeekComplete(d.weekday)}, ${getMonth(d.month)} ${d.day}';
  }
}
