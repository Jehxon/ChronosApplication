import 'package:flutter/material.dart';
import 'package:timers/models/preferences.dart';
import 'package:timers/models/color_picker.dart';
import 'package:timers/widgets/calendar/calendar_view.dart';
import 'package:timers/widgets/chronometer/chronometer_list.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeData) onChangeTheme;
  const HomePage({required this.onChangeTheme, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  static final List<Widget> widgetOptions = <Widget>[
    const ChronometerListPage(),
    const TableBasicsExample(),
  ];

  void changePage(int index) {
    Navigator.pop(context);
    if(index == selectedIndex) return;
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chronos'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: MAIN_COLOR,
                image: const DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/paysageCalmeSmall.jpg')
                    // image: AssetImage('assets/illustration_temps_qui_passe.jpg')
                    ),
              ),
              child: const SizedBox.shrink(),
            ),
            ListTile(
              leading: const Icon(Icons.timer_sharp),
              title: const Text('Chronomètres'),
              onTap: () {
                changePage(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Statistiques'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Agenda'),
              onTap: () {
                changePage(1);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Changer le thème'),
              onTap: () async {
                MAIN_COLOR = await pickColor(context, MAIN_COLOR);
                savePreferences();
                widget.onChangeTheme(
                    ThemeData(primarySwatch: toMaterialColor(MAIN_COLOR)));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Précédent'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: widgetOptions[selectedIndex],
    );
  }
}