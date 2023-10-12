import 'package:flutter/material.dart';

const Map<int, Color> _color = {
  50: Color.fromRGBO(0, 0, 0, .1),
  100: Color.fromRGBO(0, 0, 0, .2),
  200: Color.fromRGBO(0, 0, 0, .3),
  300: Color.fromRGBO(0, 0, 0, .4),
  400: Color.fromRGBO(0, 0, 0, .5),
  500: Color.fromRGBO(0, 0, 0, .6),
  600: Color.fromRGBO(0, 0, 0, .7),
  700: Color.fromRGBO(0, 0, 0, .8),
  800: Color.fromRGBO(0, 0, 0, .9),
  900: Color.fromRGBO(0, 0, 0, 1),
};

const Map<int, Color> _colorWhite = {
  50: Color.fromRGBO(255, 255, 255, .1),
  100: Color.fromRGBO(255, 255, 255, .2),
  200: Color.fromRGBO(255, 255, 255, .3),
  300: Color.fromRGBO(255, 255, 255, .4),
  400: Color.fromRGBO(255, 255, 255, .5),
  500: Color.fromRGBO(255, 255, 255, .6),
  600: Color.fromRGBO(255, 255, 255, .7),
  700: Color.fromRGBO(255, 255, 255, .8),
  800: Color.fromRGBO(255, 255, 255, .9),
  900: Color.fromRGBO(255, 255, 255, 1),
};

final appThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    secondaryContainer: Colors.grey,
    primary: MaterialColor(0xFF000000, _color),
    surface: MaterialColor(0xFFFFFFFF, _colorWhite),
    surfaceVariant: MaterialColor(0xFFFFFFFF, _colorWhite),
    onSurface: Colors.black,
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: MaterialColor(0xFF000000, _color),
  ),
  appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
    color: MaterialColor(0xFF000000, _color),
  )),
  primarySwatch: const MaterialColor(0xFF000000, _color),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
final appDarkThemeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: MaterialColor(0xFFFFFFFF, _colorWhite),
    secondary: Colors.lightBlue,
    tertiary: Colors.lightBlue,
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: MaterialColor(0xFFFFFFFF, _colorWhite),
  ),
  appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
    color: MaterialColor(0xFFFFFFFF, _colorWhite),
  )),
  primarySwatch: const MaterialColor(0xFFFFFFFF, _colorWhite),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
