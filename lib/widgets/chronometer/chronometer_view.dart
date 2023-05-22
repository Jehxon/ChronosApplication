import "dart:async";
import 'package:flutter/material.dart';
import 'package:timers/widgets/chronometer/chronometer_widget_stateless.dart';
import 'package:timers/models/chrono_class.dart';
import 'package:timers/models/color_picker.dart';
import 'package:timers/main.dart';

class ChronometerListPage extends StatefulWidget {
  const ChronometerListPage({super.key});

  @override
  State<ChronometerListPage> createState() => _ChronometerListPageState();
}

class _ChronometerListPageState extends State<ChronometerListPage> {
  Timer? updateDisplayTimer;

  // create some values
  String currentName = "";
  Color currentColor = const Color(0xff009688);

  void removeChrono(int id) {
    setState(() {
      Chronometer c =
          chronometerList.where((element) => element.id == id).first;
      c.deleteSavedFile();
      chronometerList.removeWhere((element) => element.id == id);
    });
  }

  void addChrono() {
    setState(() {
      Chronometer newChrono = Chronometer(currentID, currentName, currentColor);
      newChrono.save();
      chronometerList.add(newChrono);
    });
    currentID++;
  }

  void updateDisplay() {
    setState(() {});
  }

  // TextField callback
  void changeName(String newName) {
    setState(() => currentName = newName);
  }

  @override
  void initState() {
    super.initState();
    updateDisplayTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      updateDisplay();
    });
  }

  @override
  void dispose() {
    updateDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          primary: true,
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 30,
          crossAxisSpacing: 30,
          children: [
            for (Chronometer c in chronometerList)
              ChronoWidgetStateless(
                  chronometer: c, onDeleteChrono: removeChrono)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          newChronoDialog(context);
        },
        tooltip: 'Ajouter un chronomètre',
        child: const Icon(Icons.add),
      ),
    );
  }
  Future<void> changeCurrentColor(StateSetter setState) async {
    Color chosenColor = await pickColor(context, currentColor);
    setState(() => currentColor = chosenColor);
  }

  Future<void> newChronoDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Créer un chronomètre"),
            content: TextField(
              onChanged: changeName,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Nom du chronomètre',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: currentColor,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.circle,
                  color: currentColor,
                  size: 40,
                ),
                onPressed: () async {
                  await changeCurrentColor(setState);
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  await changeCurrentColor(setState);
                },
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(currentColor)),
                child: const Text('Couleur'),
              ),
              ElevatedButton(
                onPressed: () {
                  addChrono();
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(currentColor)),
                child: const Text('Créer'),
              ),
            ],
          );
        });
      },
    );
  }
}
