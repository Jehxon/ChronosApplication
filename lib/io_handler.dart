import 'dart:async';
import 'models/chrono_class.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

String convertChonoListToJSON(List<Chronometer> chronoList) {
  return jsonEncode(chronoList.map((e) => e.toJSON()).toList());
}

List<Chronometer> convertJSONToChronoList(String json, [onChangeChrono = doNothing]) {
  List<dynamic> paramList = jsonDecode(json);
  return paramList.mapIndexed((int i, paramMap) => Chronometer.fromJSON(i, paramMap, onChangeChrono)).toList();
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/save_chronos.json');
}

Future<File> saveStateToFile(List<Chronometer> chronoList) async {
  final file = await _localFile;
  final String json = convertChonoListToJSON(chronoList);
  // Write the file
  return file.writeAsString(json);
}

Future<List<Chronometer>> loadStateFromFile([onChangeChono = doNothing]) async {
  try {
    final file = await _localFile;
    // Read the file
    final contents = await file.readAsString();
    return convertJSONToChronoList(contents, onChangeChono);
  } catch (e) {
    // If encountering an error, return empty
    return [];
  }
}