import 'package:flutter/material.dart';
import 'package:timers/preferences.dart';
import 'package:timers/models/color_picker.dart';

class NavBar extends StatelessWidget {
  final Function(ThemeData) onChangeTheme;
  const NavBar({required this.onChangeTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart),
            title: const Text('Statistiques'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Agenda'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Changer le thème'),
            onTap: () async {
              MAIN_COLOR = await pickColor(context, MAIN_COLOR);
              savePreferences();
              onChangeTheme(ThemeData(primarySwatch: toMaterialColor(MAIN_COLOR)));
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Précédent'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {Navigator.pop(context);},
          ),
        ],
      ),
    );
  }
}