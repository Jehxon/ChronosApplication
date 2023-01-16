import "chronometerWidget.dart";
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

String convertChonoListToJSON(List<MyChronometer> chronoList) {
  List jsonList = chronoList.map((chrono) => {'name': chrono.chronoName, 'color': chrono.color?.value, 'time': chrono.currentTime}).toList();
  return jsonEncode(jsonList);
}

List<MyChronometer> convertJSONToChronoList(String json) {
  List paramList = jsonDecode(json);
  return paramList.map((paramMap) => MyChronometer(chronoName: paramMap['name'], color: Color(paramMap['color']), currentTime: paramMap['time'])).toList();
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/save_chronos.json');
}

Future<File> saveStateToFile(List<MyChronometer> chronoList) async {
  final file = await _localFile;
  final String json = convertChonoListToJSON(chronoList);
  // Write the file
  return file.writeAsString(json);
}

Future<List<MyChronometer>> loadStateFromFile() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return convertJSONToChronoList(contents);
  } catch (e) {
    // If encountering an error, return empty
    return [];
  }
}