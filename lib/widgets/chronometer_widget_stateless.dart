import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chronos/models/chrono_class.dart';

class ChronoWidgetStateless extends StatelessWidget {
  final Chronometer chronometer;
  final void Function(int) onDeleteChrono;
  final void Function(int) onStartChrono;
  final void Function(int) onStopChrono;
  final void Function(int) onResetChrono;

  const ChronoWidgetStateless({
    super.key,
    required this.chronometer,
    required this.onDeleteChrono,
    required this.onStartChrono,
    required this.onStopChrono,
    required this.onResetChrono,
  });

  String getTimeString() {
    // Compute the hours, minutes, and seconds from the elapsed time in seconds
    int hours = (chronometer.currentTime / 3600).floor();
    int minutes = ((chronometer.currentTime % 3600) / 60).floor();
    int seconds = (chronometer.currentTime % 60).floor();
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

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
                  child: const Text('Reset chronometer'),
                  onPressed: () {
                    onResetChrono(chronometer.id);
                    Navigator.of(context).pop();
                  },
                )
              ),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(chronometer.color)
                  ),
                  child: const Text('Delete chronometer'),
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
            onStopChrono(chronometer.id);
          } else {
            onStartChrono(chronometer.id);
          }
        },
        onLongPress: () {
          _chronoManagementDialog(context);
        },
        child: Container(
          height: 100,
          width: 80,
          decoration: BoxDecoration(
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
                        text: getTimeString(),
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
