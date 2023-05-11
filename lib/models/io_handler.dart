import 'dart:async';
import 'chrono_class.dart';
import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';

final chronosGlob = Glob("*.chronos");

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

String getChronoFilePath(String path, String name){
  return "$path/saved_$name.chronos";
}

void deleteSavedChrono(String name) async {
  final path = await _localPath;
  File f = File(getChronoFilePath(path, name));
  f.delete();
}

Future<List<File>> getExistingFilesHandle() async {
  final path = await _localPath;
  List<File> ret = [];
  for (var entity in chronosGlob.listSync(root: path)) {
    ret.add(File(entity.path));
  }
  return ret;
}

void saveChronoToFile(String path, Chronometer c) async {
  String name = c.name;
  String content = c.toJSONString();
  File f = File(getChronoFilePath(path, name));
  f.writeAsString(content);
}

void saveOneChronoToFile(Chronometer c) async {
  final path = await _localPath;
  saveChronoToFile(path, c);
}

void saveChronoListToFiles(List<Chronometer> chronoList) async {
  final path = await _localPath;
  for(final c in chronoList){
    saveChronoToFile(path, c);
  }
}

Future<List<Chronometer>> loadChronosFromFiles() async {
  List<Chronometer> chronoList = [];
  int id = 0;
  try {
    final files = await getExistingFilesHandle();
    for(final file in files){
      // Read the file
      final contents = await file.readAsString();
      chronoList.add(Chronometer.fromJSONString(contents, id));
      id++;
    }
    return chronoList;
  } catch (e) {
    // If encountering an error, return empty
    // print(e);
    return [];
  }
}