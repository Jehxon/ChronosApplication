import 'package:intl/date_symbol_data_local.dart';
import 'models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:timers/models/chrono_class.dart';
import 'package:timers/models/io_handler.dart';
import 'package:timers/home_page.dart';

List<Chronometer> chronometerList = [];
int currentID = 0;
Color mainColor = Colors.teal;
List<Function(Color)> colorChangeCallbacks = [];

void addThemeChangeCallback(Function(Color) func) {
  colorChangeCallbacks.add(func);
}
void removeThemeChangeCallback(Function(Color) func) {
  colorChangeCallbacks.remove(func);
}
void changeAppColor(Color c) {
  mainColor = c;
  savePreferences();
  for(int i = 0; i < colorChangeCallbacks.length; i++){
    colorChangeCallbacks[i](c);
  }
}

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  bool initialized = false;
  ThemeData theme = ThemeData(primarySwatch: toMaterialColor(mainColor));

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getData();
    super.initState();
    initializeDateFormatting();
    addThemeChangeCallback(updateColorCallback);
  }

  void getData() async {
    initPreferences();
    chronometerList = await loadChronosFromFiles();
    currentID = chronometerList.length;
    setState(() {
      initialized = true;
      theme = ThemeData(primarySwatch: toMaterialColor(mainColor));
    });
  }

  void updateColorCallback(Color c){
    setState(() {
      theme = ThemeData(primarySwatch: toMaterialColor(c));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    removeThemeChangeCallback(updateColorCallback);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        // saveChronoListToFiles(chronometerList);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        // saveChronoListToFiles(chronometerList);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return MaterialApp(
          title: 'Chronos',
          theme: theme,
          home: const HomePage()
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
