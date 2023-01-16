import "chronometerWidget.dart";
import "ioHandler.dart";
import "dart:async";
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_background/flutter_background.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronos',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  List<MyChronometer> _chronometerList = [];
  bool _initialized = false;
  bool hasPermissions = false;
  Timer? saveTimer;


  Future<void> _getPermissions() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Chronos",
      notificationText: "Chronos is running in the background.",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(name: 'chronometre', defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );

    hasPermissions = await FlutterBackground.hasPermissions;

    hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
    if(!hasPermissions){
      if (!hasPermissions) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Permissions needed'),
                content: const Text(
                    'This app cannot function without permission to execute this app in the background. This is required in order to continue the chronometers when the app is not in the foreground.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'QUIT');
                      exit(-1);
                    },
                    child: const Text('QUIT'),
                  ),
                ]);
          });
      }
    }
    await FlutterBackground.enableBackgroundExecution();
  }

  void getData() async {
    _chronometerList = await loadStateFromFile();
    setState(() => _initialized = true);
  }

  @override
  void initState() {
    getData();  //call async function.
    super.initState();
    saveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      saveStateToFile(_chronometerList);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!hasPermissions)
    {
      _getPermissions();
    }
    _chronometerList.removeWhere((element) => element.wantToDie);
    if(_initialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chronos'),
        ),
        body: Center(
          child: GridView.count(
            crossAxisCount: 2,
            primary: true,
            padding: const EdgeInsets.all(20),
            mainAxisSpacing: 30,
            crossAxisSpacing: 30,
            children: _chronometerList
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNewChronoDialog(context),
          tooltip: 'Add chronometer',
          child: const Icon(Icons.add),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chronos'),
        ),
        body: const Center(
          child : CircularProgressIndicator(),
        ),
      );
    }
  }

  // create some values
  String currentName = "";
  Color currentColor = const Color(0xff009688);

  // TextField callback
  void changeName(String newName)
  {
    setState(() => currentName = newName);
  }

  // ValueChanged<Color> callback
  void changeColor(Color color, setState) {
    setState(() => currentColor = color);
  }

  Future<void> _showNewChronoDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Create chronometer"),
            content: TextField(
              onChanged: changeName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Name of the chronometer',
              ),
            ),
            actions: <Widget>[
              Icon(
                Icons.circle,
                color: currentColor,
                size: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  _pickColorDialog(context, setState);
                },
                child: const Text('Change color'),
              ),
              ElevatedButton(
                child: const Text('Create'),
                onPressed: () {
                  _addChrono();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _pickColorDialog(BuildContext context, setState) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (Color c) {
                changeColor(c, setState);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _addChrono(){
    setState(() {
      _chronometerList = [..._chronometerList, MyChronometer(color: currentColor, chronoName: currentName, currentTime: 0,)];
    });
  }
}
