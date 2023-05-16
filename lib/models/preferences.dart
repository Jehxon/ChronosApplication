import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timers/main.dart';

late final SharedPreferences prefs;

Future<void> initPreferences() async {
  prefs = await SharedPreferences.getInstance();
  loadPreferences();
}

void loadPreferences() {
  final int? colorValue = prefs.getInt('main_color');
  if(colorValue != null){
    mainColor = Color(colorValue);
  }
}

void savePreferences() async {
  await prefs.setInt('main_color', mainColor.value);
}

MaterialColor toMaterialColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;

  final Map<int, Color> shades = {
    50: Color.fromRGBO(red, green, blue, .1),
    100: Color.fromRGBO(red, green, blue, .2),
    200: Color.fromRGBO(red, green, blue, .3),
    300: Color.fromRGBO(red, green, blue, .4),
    400: Color.fromRGBO(red, green, blue, .5),
    500: Color.fromRGBO(red, green, blue, .6),
    600: Color.fromRGBO(red, green, blue, .7),
    700: Color.fromRGBO(red, green, blue, .8),
    800: Color.fromRGBO(red, green, blue, .9),
    900: Color.fromRGBO(red, green, blue, 1),
  };
  return MaterialColor(color.value, shades);
}