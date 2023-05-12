import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/paysageCalmeSmall.jpg')
                  // image: AssetImage('assets/illustration_temps_qui_passe.jpg')
              ),
            ),
            child: SizedBox.shrink(),
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
            title: const Text('Paramètres'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Revenir'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {Navigator.pop(context);},
          ),
        ],
      ),
    );
  }
}