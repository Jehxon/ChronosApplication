import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:timers/models/chrono_class.dart';

class ChronoWidgetStateless extends StatelessWidget {
  final Chronometer chronometer;
  final void Function(int) onDeleteChrono;

  const ChronoWidgetStateless({
    super.key,
    required this.chronometer,
    required this.onDeleteChrono,
  });

  Future<void> _chronoManagementDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
            title: Center(
                child: Text(
                  chronometer.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
            ),
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(chronometer.color)
                  ),
                  child: const Text('Réinitialiser'),
                  onPressed: () {
                    chronometer.reset();
                    Navigator.of(context).pop();
                  },
                )
              ),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(chronometer.color)
                  ),
                  child: const Text('Supprimer'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDeleteChrono(chronometer.id);
                    // dispose();
                  },
                ),
              ),
            ],
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
          if(chronometer.isRunning) {
            chronometer.stop();
          } else {
            chronometer.start();
          }
        },
        onLongPress: () {
          _chronoManagementDialog(context);
        },
        child: Container(
          height: 100,
          width: 80,
          decoration: BoxDecoration(
              color: chronometer.isRunning ? chronometer.color.withOpacity(0.15) : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              //border corner radius
              border: Border.all(
                width: 3,
                color: chronometer.color,
              )
          ),
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
                overflowReplacement: const Text('Le nom choisi est trop long !',
                  textAlign: TextAlign.center,),
                TextSpan(
                    text: '${chronometer.name}\n',
                    style: const TextStyle(color: Colors.grey,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text: chronometer.getRunningTimeString(),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
