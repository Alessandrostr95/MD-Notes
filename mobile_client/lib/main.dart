// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'pages/markdownPage.dart';
import 'pages/imagePage.dart';
import 'pages/homePage.dart';
import 'pages/settingsPage.dart';
import 'pages/markdownEditorPage.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() {
  runApp(const MyApp());
}

/// Main page that starts the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        primarySwatch: Colors.orange,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      initial: AdaptiveThemeMode.light,
      builder: (_theme, _darkTheme) => MaterialApp(
        title: 'MD Notes',
        debugShowCheckedModeBanner: false,
        theme: _theme, 
        darkTheme: _darkTheme,
        initialRoute: "/",
        // initialRoute: SettingsPage.PATH,
        routes: {
          "/": (context) => const HomePage(title: "MD Notes"),
          MarkDownPage.PATH: (context) => const MarkDownPage(),
          ImagePage.PATH: (context) => const ImagePage(),
          SettingsPage.PATH: (context) => const SettingsPage(),
          MarkdownEditorPage.PATH: (context) => const MarkdownEditorPage(),
        },
      ),
    );
  }
}
