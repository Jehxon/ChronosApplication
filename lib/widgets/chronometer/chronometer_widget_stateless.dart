import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:timers/models/chrono_class.dart';
import 'package:timers/models/color_picker.dart';
import 'package:timers/models/text_picker.dart';
import 'package:timers/models/confirm_dialog.dart';

class InDialogButton extends StatelessWidget {
  final String name;
  final Color color;
  final void Function() onPressed;
  final double width;
  final double height;

  const InDialogButton(
      {super.key,
      required this.name,
      required this.height,
      required this.width,
      required this.color,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(color),
          fixedSize: MaterialStatePropertyAll<Size>(Size(width, height)),
        ),
        onPressed: onPressed,
        child: Text(name),
      ),
    );
  }
}

class ChronoWidgetStateless extends StatelessWidget {
  final Chronometer chronometer;
  final void Function(int) onDeleteChrono;

  const ChronoWidgetStateless({
    super.key,
    required this.chronometer,
    required this.onDeleteChrono,
  });

  Future<void> chronoManagementDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(10),
            title: Column(
              children: [
                Text(
                  chronometer.name,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Wrap(
                    children: [
                      InDialogButton(
                        name: "Renommer",
                        width: 110,
                        height: 40,
                        color: chronometer.color,
                        onPressed: () async {
                          chronometer.deleteSavedFile();
                          String newName = await pickText(
                              context, chronometer.name, chronometer.color);
                          chronometer.name = newName;
                          chronometer.save();
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                      ),
                      InDialogButton(
                        name: "Changer la couleur",
                        width: 150,
                        height: 40,
                        color: chronometer.color,
                        onPressed: () async {
                          Color newColor =
                              await pickColor(context, chronometer.color);
                          chronometer.color = newColor;
                          chronometer.save();
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                      ),
                      InDialogButton(
                        name: "Réinitialiser",
                        width: 140,
                        height: 40,
                        color: chronometer.color,
                        onPressed: () {
                          chronometer.reset();
                          Navigator.of(context).pop();
                        },
                      ),
                      InDialogButton(
                        name: "Supprimer",
                        width: 120,
                        height: 40,
                        color: chronometer.color,
                        onPressed: () async {
                          bool confirm = await showConfirmDialog(
                              context, chronometer.color);
                          if (confirm) {
                            onDeleteChrono(chronometer.id);
                          }
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Material(
      elevation: 10,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      //border corner radius
      child: InkWell(
        onTap: () {
          if (chronometer.isRunning) {
            chronometer.stop();
          } else {
            chronometer.start();
          }
        },
        onLongPress: () {
          chronoManagementDialog(context);
        },
        child: Container(
          height: 100,
          width: 80,
          decoration: BoxDecoration(
              color: chronometer.isRunning
                  ? chronometer.color.withOpacity(0.15)
                  : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              //border corner radius
              border: Border.all(
                width: 3,
                color: chronometer.color,
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.timer_sharp,
                color: chronometer.color,
                size: 50,
              ),
              AutoSizeText.rich(
                minFontSize: 8,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflowReplacement: const Text(
                  'Le nom choisi est trop long !',
                  textAlign: TextAlign.center,
                ),
                TextSpan(
                    text: '${chronometer.name}\n',
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                          text: chronometer.getRunningTimeString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
