import 'dart:async';
import 'package:flutter/material.dart';

void doNothing(){}

class Chronometer {
  int id;
  int currentTime = 0;
  String name = "";
  Color color = Colors.white;
  bool isRunning = false;
  Timer? timer;
  Function onChange = doNothing;

  Chronometer(this.id, this.currentTime, this.name, this.color, [this.onChange = doNothing]);

  Chronometer.fromJSON(this.id, Map<String, dynamic> json, [this.onChange = doNothing]){
    currentTime = json['time'];
    name = json['name'];
    color = Color(json['color']);
  }

  startTimer(){
    isRunning = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime++;
      onChange();
    });
  }

  stopTimer(){
    isRunning = false;
    timer?.cancel();
  }

  resetTimer(){
    currentTime = 0;
    // stopTimer();
  }

  Map<String, dynamic> toJSON() => {
    'name': name,
    'color': color.value,
    'time': currentTime,
  };
}
