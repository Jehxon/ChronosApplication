import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(BuildContext context, Color buttonColor) async {
  bool choice = false;
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
            child: Text(
              'Êtes-vous sûr ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
        actions: <Widget>[
          Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(buttonColor)
                ),
                child: const Text('Oui'),
                onPressed: () {
                  Navigator.of(context).pop();
                  choice = true;
                },
              )
          ),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(buttonColor)
              ),
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
                choice = false;
              },
            ),
          ),
        ],
      );
    },
  );
  return choice;
}