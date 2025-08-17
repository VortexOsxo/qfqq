import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
    onPrimary: Colors.white
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.blueAccent),
  ),
  useMaterial3: true,
);

// TODO: Implement dark mode support
// final ThemeData darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: Colors.blue,
//     brightness: Brightness.dark,
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Colors.white),
//     bodyMedium: TextStyle(color: Colors.white70),
//     titleLarge: TextStyle(color: Colors.lightBlueAccent),
//   ),
//   useMaterial3: true,
// );
