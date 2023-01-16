import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MyChronometer extends StatefulWidget {
  final String chronoName;
  final Color? color;
  int currentTime;
  bool wantToDie = false;

  MyChronometer({super.key, required this.chronoName, required this.color, required this.currentTime});

  @override
  Chronometer createState() => Chronometer();
}

class Chronometer extends State<MyChronometer> with AutomaticKeepAliveClientMixin {
  // Declare a variable to hold the current value of the timer is hours, minutes and seconds
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  // Declare a variable to hold the Timer
  Timer? _timer;

  // Declare a variable to hold the isRunning state
  bool _isRunning = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _updateTimeVisualisation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      elevation: 10,
      borderRadius: const BorderRadius.all(Radius.circular(8)), //border corner radius
      child: InkWell(
        onTap: _isRunning ? _stop : _start,
        onLongPress: () {
          _chronoManagementDialog(context);
        },
        child: Container(
          height: 100,
          width: 80,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)), //border corner radius
              border: Border.all(
              width: 3,
              color: widget.color!,
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.timer_sharp,
                color: widget.color,
                size: 50,
              ),
              AutoSizeText.rich(
                minFontSize: 8,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflowReplacement: const Text('Le nom choisi est trop long !', textAlign: TextAlign.center,),
                TextSpan(
                  text: '${widget.chronoName}\n',
                  style: const TextStyle(color: Colors.grey,fontSize: 20.0, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                        // Display the timer in 'hh:mm:ss' format
                        text: "${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold)
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

  void _updateTimeVisualisation() {
    setState(() {
      // Compute the hours, minutes, and seconds from the elapsed time in seconds
      _hours = (widget.currentTime / 3600).floor();
      _minutes = ((widget.currentTime % 3600) / 60).floor();
      _seconds = (widget.currentTime % 60).floor();
    });
  }

  void _start() {
    // Set the isRunning variable to true
    setState(() {
      _isRunning = true;
    });

    // Create a new Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Increment the current time by 1
      setState(() {
        widget.currentTime++;
      });
      _updateTimeVisualisation();
    });
  }

  void _stop() {
    // Set the isRunning variable to false
    setState(() {
      _isRunning = false;
    });
    // Cancel the timer
    _timer?.cancel();
  }

  void _reset() {
    // Set the currentTime variable to false
    setState(() {
      widget.currentTime = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    });
  }

  Future<void> _chronoManagementDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
            title: Text(widget.chronoName),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Reset chronometer'),
                onPressed: () {
                  _reset();
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Delete chronometer'),
                onPressed: () {
                  widget.wantToDie = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}
