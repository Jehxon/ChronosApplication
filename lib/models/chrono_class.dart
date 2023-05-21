import 'package:flutter/material.dart';
import 'dart:convert';
import 'calendar_events.dart';
import "io_handler.dart";

class TimeSpan {
  DateTime start;
  DateTime stop;
  TimeSpan(this.start, this.stop);
}

String formatDurationToString(Duration duration){
  String days = duration.inDays > 0 ? '${duration.inDays.toString()} jour${duration.inDays == 1 ? '' : 's'} ' : '';
  String formattedDuration = '$days'
      '${(duration.inHours % 24).toString().padLeft(2, '0')}:'
      '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
      '${(duration.inSeconds % 60).toString().padLeft(2, '0')}.'
      '${((duration.inMilliseconds % 1000)/100).floor().toString().padLeft(1, '0')}';
  return formattedDuration;
}

Duration computeOverlap(DateTime start1, DateTime stop1, DateTime start2, DateTime stop2){
  if (start1.isAfter(stop2) || stop1.isBefore(start2)) {
    return Duration.zero;
  }
  DateTime overlapStart = start1.isAfter(start2) ? start1 : start2;
  DateTime overlapStop = stop1.isBefore(stop2) ? stop1 : stop2;
  Duration overlapDuration = overlapStop.difference(overlapStart);
  return overlapDuration;
}

class Chronometer {
  int id;
  String name = "";
  Color color = Colors.white;
  bool isRunning = false;
  DateTime lastReset;
  late List<DateTime> startTimestamps;
  late List<DateTime> stopTimestamps;
  late List<Duration> sessionsDurations;

  Chronometer(this.id, this.name, this.color, {List<DateTime>? startTimestamps, List<DateTime>? stopTimestamps, DateTime? lastReset}) : lastReset = lastReset ?? DateTime.now() {
    this.startTimestamps = startTimestamps ?? [];
    this.stopTimestamps = stopTimestamps ?? [];
    sessionsDurations = getSessionsDurations();
  }

  static Chronometer fromJSONString(String jsonString, int id){
    Map<String, dynamic> json = jsonDecode(jsonString);
    String name = json['name'];
    Color color = Color(json['color']);
    List<DateTime> startTimestamps = json['startTs'].map((e) => DateTime.parse(e)).toList().cast<DateTime>();
    List<DateTime> stopTimestamps = json['stopTs'].map((e) => DateTime.parse(e)).toList().cast<DateTime>();
    DateTime lastReset = DateTime.parse(json['lastReset']);
    return Chronometer(id, name, color, startTimestamps: startTimestamps, stopTimestamps: stopTimestamps, lastReset: lastReset);
  }

  start(){
    isRunning = true;
    startTimestamps.add(DateTime.now());
    save();
  }

  stop(){
    isRunning = false;
    stopTimestamps.add(DateTime.now());
    int n = startTimestamps.length;
    sessionsDurations.add(stopTimestamps[n-1].difference(startTimestamps[n-1]));
    save();
  }

  reset(){
    lastReset = DateTime.now();
    save();
  }

  save(){
    saveOneChronoToFile(this);
  }

  List<CalendarEvent> toCalendarEventList() {
    List<CalendarEvent> events = <CalendarEvent>[];
    for(int i = 0; i < stopTimestamps.length; i++){
      events.add(CalendarEvent(name, startTimestamps[i], stopTimestamps[i], color, false));
    }
    if(isRunning) {
      events.add(CalendarEvent(name, startTimestamps[startTimestamps.length-1], DateTime.now(), color, false));
    }
    return events;
  }

  List<Duration> getSessionsDurations(){
    if(startTimestamps.length > stopTimestamps.length){
      isRunning = true;
    }
    return [for (int i=0; i < stopTimestamps.length; i++) stopTimestamps[i].difference(startTimestamps[i])];
  }

  String getRunningTimeString() {
    // Compute the days, hours, minutes, seconds and milliseconds of running time since last reset
    Duration duration = getRunningDurationSinceLastReset();
    return formatDurationToString(duration);
  }

  Duration getRunningDurationSinceLastReset(){
    Duration runningDuration = Duration.zero;

    for (int i = 0; i < stopTimestamps.length; i++){
      if(stopTimestamps[i].isBefore(lastReset)) continue;
      if(startTimestamps[i].isBefore(lastReset)) {
        runningDuration -= lastReset.difference(startTimestamps[i]);
      }
      runningDuration += sessionsDurations[i];
    }
    // Deal with current period if is running
    if(isRunning){
      DateTime lastStart = startTimestamps[startTimestamps.length-1];
      DateTime lastEvent = lastStart.isBefore(lastReset) ? lastReset : lastStart;
      runningDuration += DateTime.now().difference(lastEvent);
    }
    return runningDuration;
  }

  Duration getTotalRunningDuration(){
    Duration totalRunningDuration = Duration.zero;

    for (int i = 0; i < sessionsDurations.length; i++){
      totalRunningDuration += sessionsDurations[i];
    }
    // Deal with current period if is running
    if(isRunning){
      DateTime lastStart = startTimestamps[startTimestamps.length-1];
      totalRunningDuration += DateTime.now().difference(lastStart);
    }
    return totalRunningDuration;
  }

  Duration getTotalDurationOnSpecificWeekDay(int weekDay) {
    Duration totalDuration = Duration.zero;
    for (int i = 0; i < stopTimestamps.length; i++) {
      DateTime start = startTimestamps[i];
      DateTime stop = stopTimestamps[i];

      DateTime lastWeekDay = DateTime(start.year, start.month, start.day - (start.weekday - weekDay) % 7);
      DateTime nextWeekDay = DateTime(stop.year, stop.month, stop.day - (stop.weekday - weekDay) % 7 + 7);

      List<TimeSpan> weekDaysInBetween = [];
      DateTime t = lastWeekDay;
      while(t.isBefore(nextWeekDay)){
        weekDaysInBetween.add(TimeSpan(t, t.add(const Duration(days: 1))));
        t = t.add(const Duration(days: 7));
      }

      for(TimeSpan ts in weekDaysInBetween){
        totalDuration += computeOverlap(ts.start, ts.stop, start, stop);
      }
    }

    if(isRunning){
      DateTime start = startTimestamps[startTimestamps.length-1];
      DateTime stop = DateTime.now();

      DateTime lastWeekDay = DateTime(start.year, start.month, start.day - (start.weekday - weekDay) % 7);
      DateTime nextWeekDay = DateTime(stop.year, stop.month, stop.day - (stop.weekday - weekDay) % 7 + 7);
      List<TimeSpan> weekDaysInBetween = [];
      DateTime t = lastWeekDay;
      while(t.isBefore(nextWeekDay)){
        weekDaysInBetween.add(TimeSpan(t, t.add(const Duration(days: 1))));
        t = t.add(const Duration(days: 7));
      }

      for(TimeSpan ts in weekDaysInBetween){
        totalDuration += computeOverlap(ts.start, ts.stop, start, stop);
      }
    }
    return totalDuration;
  }

  Duration getOverlappingRunningTime(DateTime periodStart, DateTime periodStop) {
    Duration totalDuration = Duration.zero;
    DateTime now = DateTime.now();

    for (int i = 0; i < stopTimestamps.length; i++) {
      DateTime start = startTimestamps[i];
      DateTime stop = stopTimestamps[i];
      totalDuration += computeOverlap(start, stop, periodStart, periodStop);
    }
    if(isRunning){
      DateTime start = startTimestamps[startTimestamps.length-1];
      totalDuration += computeOverlap(start, now, periodStart, periodStop);
    }
    return totalDuration;
  }

  Duration getTotalDurationToday() {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    return getOverlappingRunningTime(todayStart, now);
  }

  Duration getTotalDurationThisWeek() {
    DateTime now = DateTime.now();
    DateTime weekStart = DateTime(now.year, now.month, now.day - now.weekday - 1);
    return getOverlappingRunningTime(weekStart, now);
  }

  String getStatistics(){
    String currentRunningTime = getRunningTimeString();
    Duration totalRunningTime = getTotalRunningDuration();
    Duration todayRunningTime = getTotalDurationToday();
    Duration thisWeekRunningTime = getTotalDurationThisWeek();

    Duration mondaysDuration = getTotalDurationOnSpecificWeekDay(DateTime.monday);
    Duration tuesdaysDuration = getTotalDurationOnSpecificWeekDay(DateTime.tuesday);
    Duration wednesdaysDuration = getTotalDurationOnSpecificWeekDay(DateTime.wednesday);
    Duration thursdaysDuration = getTotalDurationOnSpecificWeekDay(DateTime.thursday);
    Duration fridaysDuration = getTotalDurationOnSpecificWeekDay(DateTime.friday);
    Duration saturdaysDuration = getTotalDurationOnSpecificWeekDay(DateTime.saturday);
    Duration sundaysDuration = getTotalDurationOnSpecificWeekDay(DateTime.sunday);

    double mondayPercentage = totalRunningTime.inSeconds == 0 ? 0 : mondaysDuration.inSeconds / totalRunningTime.inSeconds * 100;
    double tuesdayPercentage = totalRunningTime.inSeconds == 0 ? 0 : tuesdaysDuration.inSeconds / totalRunningTime.inSeconds * 100;
    double wednesdayPercentage = totalRunningTime.inSeconds == 0 ? 0 : wednesdaysDuration.inSeconds / totalRunningTime.inSeconds * 100;
    double thursdayPercentage = totalRunningTime.inSeconds == 0 ? 0 : thursdaysDuration.inSeconds / totalRunningTime.inSeconds * 100;
    double fridayPercentage = totalRunningTime.inSeconds == 0 ? 0 : fridaysDuration.inSeconds / totalRunningTime.inSeconds * 100;
    double saturdayPercentage = totalRunningTime.inSeconds == 0 ? 0 : saturdaysDuration.inSeconds / totalRunningTime.inSeconds * 100;
    double sundayPercentage = totalRunningTime.inSeconds == 0 ? 0 : sundaysDuration.inSeconds / totalRunningTime.inSeconds * 100;

    String statistics =
      "Temps en cours : $currentRunningTime\n"
      "Total du temps actif : ${formatDurationToString(totalRunningTime)}\n"
      "Temps passé aujourd'hui : ${formatDurationToString(todayRunningTime)}\n"
      "Temps passé cette semaine : ${formatDurationToString(thisWeekRunningTime)}\n\n"
      "Temps passé par jour :\n"
      "\t\u2022 lundis : ${formatDurationToString(mondaysDuration)}\t\t\t(${mondayPercentage.toStringAsFixed(2)}%)\n"
      "\t\u2022 mardis : ${formatDurationToString(tuesdaysDuration)}\t\t\t(${tuesdayPercentage.toStringAsFixed(2)}%)\n"
      "\t\u2022 mercredis : ${formatDurationToString(wednesdaysDuration)}\t\t\t(${wednesdayPercentage.toStringAsFixed(2)}%)\n"
      "\t\u2022 jeudis : ${formatDurationToString(thursdaysDuration)}\t\t\t(${thursdayPercentage.toStringAsFixed(2)}%)\n"
      "\t\u2022 vendredis : ${formatDurationToString(fridaysDuration)}\t\t\t(${fridayPercentage.toStringAsFixed(2)}%)\n"
      "\t\u2022 samedis : ${formatDurationToString(saturdaysDuration)}\t\t\t(${saturdayPercentage.toStringAsFixed(2)}%)\n"
      "\t\u2022 dimanches : ${formatDurationToString(sundaysDuration)}\t\t\t(${sundayPercentage.toStringAsFixed(2)}%)\n";
    return statistics;
  }

  static List<int> getDaysHourMinSecMilli(Duration d){
    int days = d.inDays;
    int hours = d.inHours % 24;
    int minutes = d.inMinutes % 60;
    int seconds = d.inSeconds % 60;
    int milliseconds = d.inMilliseconds % 1000;

    return([days, hours, minutes, seconds, milliseconds]);
  }

  String toJSONString() {
    return jsonEncode({
      'name': name,
      'color': color.value,
      'startTs': startTimestamps.map((e) => e.toIso8601String()).toList(),
      'stopTs': stopTimestamps.map((e) => e.toIso8601String()).toList(),
      'lastReset': lastReset.toIso8601String(),
    });
  }

}
