import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotto_app/pages/login.dart';
import 'package:flutter_localization/flutter_localization.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0xFF6D6C6C)),
          trackColor: WidgetStateProperty.all(Colors.white),
          thickness: WidgetStateProperty.all(8),
          radius: const Radius.circular(10),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 8, 8),
        ),
        textTheme: GoogleFonts.sarabunTextTheme(),
      ),
      home: Login(),
    );
  }
}
