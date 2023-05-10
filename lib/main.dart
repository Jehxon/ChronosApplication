import 'widgets/chronometer_widget_stateless.dart';
import 'models/chrono_class.dart';
import "io_handler.dart";
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

class HomePageState extends State<HomePage> {

  List<Chronometer> _chronometerList = [];
  bool _initialized = false;
  Timer? saveTimer;
  int _currentID = 0;

  // create some values
  String _currentName = "";
  Color _currentColor = const Color(0xff009688);


  void _getData() async {
    _chronometerList = await loadStateFromFile(_updateDisplay);
    _currentID = _chronometerList.length;
    setState(() => _initialized = true);
  }

  void _startChrono(int id) {
    setState(() {
      _chronometerList.where((element) => element.id == id).first.startTimer();
    });
  }

  void _stopChrono(int id) {
    setState(() {
      _chronometerList.where((element) => element.id == id).first.stopTimer();
    });
  }

  void _resetChrono(int id) {
    setState(() {
      _chronometerList.where((element) => element.id == id).first.resetTimer();
    });
  }

  void _removeChrono(int id) {
    setState(() {
      _chronometerList.removeWhere((element) => element.id == id);
    });
  }

  void _addChrono(){
    setState(() {
      _chronometerList = [..._chronometerList, Chronometer(_currentID, 0, _currentName, _currentColor, _updateDisplay)];
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
    _getData();  //call async function.
    saveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      saveStateToFile(_chronometerList);
    });
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
                    onDeleteChrono: _removeChrono,
                    onStartChrono: _startChrono,
                    onStopChrono: _stopChrono,
                    onResetChrono: _resetChrono)
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
