import 'package:flutter/material.dart';
import 'package:timers/main.dart';
import 'package:timers/models/chrono_class.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: chronometerList.length,
        itemBuilder: (BuildContext context, int index) {
          Chronometer c = chronometerList[index];
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                width: 3,
                color: c.color,
              )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    c.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: c.color,
                    ),
                  ),
                ),
                Text(
                  c.getStatistics(),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 25,
        ),
      ));
  }
}
