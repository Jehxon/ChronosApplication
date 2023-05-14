import 'preferences.dart';
import 'package:flutter/material.dart';
import 'package:timers/models/chrono_class.dart';
import 'package:timers/models/io_handler.dart';
import 'package:timers/widgets/nav_bar/nav_bar.dart';

List<Chronometer> chronometerList = [];
int currentID = 0;

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
  ThemeData theme = ThemeData(primarySwatch: toMaterialColor(MAIN_COLOR));

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getData();
    super.initState();
  }

  void getData() async {
    initPreferences();
    chronometerList = await loadChronosFromFiles();
    currentID = chronometerList.length;
    setState(() {
      initialized = true;
      theme = ThemeData(primarySwatch: toMaterialColor(MAIN_COLOR));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
          home: HomePage(
            onChangeTheme: (newTheme) {
              setState(() {
                theme = newTheme;
              });
            },
          ));
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
