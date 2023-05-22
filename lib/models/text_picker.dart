import 'package:flutter/material.dart';

Future<String> pickText(BuildContext context, String initString, Color color) async {
  String chosenString = initString;
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Choix du nom'),
        content: TextFormField(
          onChanged: (String s) {chosenString = s;},
          initialValue: initString,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: color,
                width: 2.0,
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              chosenString = initString;
              Navigator.of(context).pop();
            },
            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(color)),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(color)),
            child: const Text('Valider'),
          ),],
      );
    },
  );
  return chosenString;
}