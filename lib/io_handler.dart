import 'dart:async';
import 'models/chrono_class.dart';
import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';

final chronosGlob = Glob("*.chronos");

Future<String> getDirPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

String getChronoFilePath(String path, String name){
  return "$path/saved_$name.chronos";
}

void deleteSavedChrono(String name) async {
  final path = await getDirPath();
  File f = File(getChronoFilePath(path, name));
  f.delete();
}

Future<List<File>> getExistingFilesHandle() async {
  final path = await getDirPath();
  List<File> ret = [];
  for (var entity in chronosGlob.listSync(root: path)) {
    ret.add(File(entity.path));
  }
  return ret;
}

void saveChronosToFiles(List<Chronometer> chronoList) async {
  final path = await getDirPath();
  for(final c in chronoList){
    String name = c.name;
    String content = c.toJSONString();
    File f = File(getChronoFilePath(path, name));
    f.writeAsString(content);
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