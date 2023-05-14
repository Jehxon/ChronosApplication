import 'package:flutter/material.dart';
import 'dart:convert';
import "io_handler.dart";

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
    saveOneChronoToFile(this);
  }

  stop(){
    isRunning = false;
    stopTimestamps.add(DateTime.now());
    int n = startTimestamps.length;
    sessionsDurations.add(stopTimestamps[n-1].difference(startTimestamps[n-1]));
    saveOneChronoToFile(this);
  }

  reset(){
    lastReset = DateTime.now();
    saveOneChronoToFile(this);
  }

  List<Duration> getSessionsDurations(){
    if(startTimestamps.length > stopTimestamps.length){
      isRunning = true;
    }
    return [for (int i=0; i < stopTimestamps.length; i++) stopTimestamps[i].difference(startTimestamps[i])];
  }

  String getRunningTimeString() {
    // Compute the days, hours, minutes, seconds and milliseconds of running time since last reset
    Duration duration = getRunningDuration();
    String days = duration.inDays > 0 ? '${duration.inDays.toString()} jour${duration.inDays == 1 ? '' : 's'} ' : '';
    String formattedDuration = '$days'
        '${(duration.inHours % 24).toString().padLeft(2, '0')}:'
        '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(duration.inSeconds % 60).toString().padLeft(2, '0')}.'
        '${((duration.inMilliseconds % 1000)/100).floor().toString().padLeft(1, '0')}';
    return formattedDuration;
  }

  Duration getRunningDuration(){
    Duration totalRunningDuration = Duration.zero;

    for (int i = 0; i < stopTimestamps.length; i++){
      if(stopTimestamps[i].isBefore(lastReset)) continue;
      if(startTimestamps[i].isBefore(lastReset)) {
        totalRunningDuration -= lastReset.difference(startTimestamps[i]);
      }
      totalRunningDuration += sessionsDurations[i];
    }
    // Deal with current period if is running
    if(isRunning){
      DateTime lastStart = startTimestamps[startTimestamps.length-1];
      DateTime lastEvent = lastStart.isBefore(lastReset) ? lastReset : lastStart;
      totalRunningDuration += DateTime.now().difference(lastEvent);
    }
    return totalRunningDuration;
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
