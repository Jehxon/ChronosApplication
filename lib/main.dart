import 'widgets/chronometer_widget_stateless.dart';
import 'models/chrono_class.dart';
import 'models/io_handler.dart';
import "dart:async";
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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

class HomePageState extends State<HomePage> with WidgetsBindingObserver{

  List<Chronometer> _chronometerList = [];
  bool _initialized = false;
  Timer? updateDisplayTimer;
  int _currentID = 0;

  // create some values
  String _currentName = "";
  Color _currentColor = const Color(0xff009688);


  void _getData() async {
    _chronometerList = await loadChronosFromFiles();
    _currentID = _chronometerList.length;
    setState(() => _initialized = true);
  }

  void _removeChrono(int id) {
    setState(() {
      Chronometer c = _chronometerList.where((element) => element.id == id).first;
      deleteSavedChrono(c.name);
      _chronometerList.removeWhere((element) => element.id == id);
    });
  }

  void _addChrono(){
    setState(() {
      _chronometerList = [..._chronometerList, Chronometer(_currentID, _currentName, _currentColor)];
    });
    _currentID++;
  }

  void _updateDisplay(){
    setState(() {  });
  }

  // TextField callback
  void _changeName(String newName) {
    setState(() => _currentName = newName);
  }

  // ValueChanged<Color> callback
  void _changeColor(Color color, setState) {
    setState(() => _currentColor = color);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _getData();
    updateDisplayTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateDisplay();
    });
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        saveChronoListToFiles(_chronometerList);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        saveChronoListToFiles(_chronometerList);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              for (Chronometer c in _chronometerList)
                ChronoWidgetStateless(
                    chronometer: c,
                    onDeleteChrono: _removeChrono)
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showNewChronoDialog(context);
            },
          tooltip: 'Ajouter un chronomètre',
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

  Future<void> _showNewChronoDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Créer un chronomètre"),
            content: TextField(
              onChanged: _changeName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nom du chronomètre',
              ),
            ),
            actions: <Widget>[
              Icon(
                Icons.circle,
                color: _currentColor,
                size: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  _pickColorDialog(context, setState);
                },
                child: const Text('Couleur'),
              ),
              ElevatedButton(
                child: const Text('Créer'),
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
          title: const Text('Choix de la couleur'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _currentColor,
              onColorChanged: (Color c) {
                _changeColor(c, setState);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
