import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timers/main.dart';
import 'package:timers/models/calendar_events.dart';
import 'package:timers/models/chrono_class.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  void updateColorCallback(Color c){
    setState(() { });
  }

  @override
  void initState() {
    super.initState();
    addThemeChangeCallback(updateColorCallback);
  }

  @override
  void dispose() {
    removeThemeChangeCallback(updateColorCallback);
    super.dispose();
  }

  List<CalendarEvent> getDataSource(List<Chronometer> chronometerList) {
    final List<CalendarEvent> events = <CalendarEvent>[];
    for(Chronometer c in chronometerList) {
      events.addAll(c.toCalendarEventList());
    }
    return events;
  }

  Color computeTextColor(Color c) {
    if(c.computeLuminance() <= 0.5) {
      return c;
    }
    HSLColor hsl = HSLColor.fromColor(c);
    HSLColor hslDark = hsl.withLightness(0.4);

    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.week,
        allowedViews: const [
          CalendarView.day,
          CalendarView.week,
          CalendarView.workWeek,
          CalendarView.timelineWeek,
          CalendarView.timelineMonth
        ],
        timeSlotViewSettings: TimeSlotViewSettings(
          nonWorkingDays: const <int>[DateTime.saturday, DateTime.sunday],
          timeFormat: 'HH:mm',
          timeInterval: const Duration(minutes: 30),
          timeTextStyle: TextStyle(
            fontSize: 13,
            color: computeTextColor(mainColor),
          ),
          minimumAppointmentDuration: const Duration(minutes: 15),
        ),
        firstDayOfWeek: 1,
        dataSource: EventDataSource(getDataSource(chronometerList)),
        initialDisplayDate: DateTime.now(),
      ),
    );
  }
}