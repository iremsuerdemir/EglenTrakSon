import 'package:flutter/material.dart';
import 'package:gorsel_programlama_proje/models/card_items.dart';
import 'package:gorsel_programlama_proje/pages/category_page.dart';
import 'package:gorsel_programlama_proje/pages/choice_game_detail_menu_page.dart';
import 'package:gorsel_programlama_proje/pages/quiz_page.dart';
import 'package:gorsel_programlama_proje/pages/quizintropage.dart';
import 'package:gorsel_programlama_proje/pages/score_history_page.dart';
import 'package:gorsel_programlama_proje/pages/score_screen.dart';
import 'package:gorsel_programlama_proje/pages/time_finish_page.dart';

void main() {
  const primaryColor = Color.fromARGB(255, 207, 47, 35);
  const backgroundColor = Color.fromARGB(255, 50, 59, 63);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: Colors.blue,
          surface: backgroundColor,
          surfaceContainer: const Color.fromARGB(255, 54, 61, 65),
          onPrimary: Colors.white, //textField
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          toolbarHeight: 50,
          actionsPadding: EdgeInsets.only(right: 10),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 30),
          bodyMedium: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 12),
          headlineMedium: TextStyle(fontSize: 24), // Card header
          headlineSmall: TextStyle(
            fontSize: 12,
            color: const Color.fromARGB(255, 96, 111, 117), // Card description
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor: WidgetStateProperty.all(primaryColor),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ),
      home: QuizIntroPage(),
    ),
  );
}
