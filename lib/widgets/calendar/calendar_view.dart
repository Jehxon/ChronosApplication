import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timers/main.dart';

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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.week,
        timeSlotViewSettings: const TimeSlotViewSettings(
          nonWorkingDays: <int>[DateTime.friday, DateTime.saturday],
          timeFormat: 'HH:mm',
        ),
        firstDayOfWeek: 1,
      ),
    );
  }
}