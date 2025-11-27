import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';

class MetanoiaApp extends StatelessWidget {
  const MetanoiaApp({super.key});
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0C2F37);
    const textColor = Color(0xFFF5F3F0);
    
    final theme = ThemeData(
      colorSchemeSeed: const Color(0xFF4F46E5),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: textColor),
        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: textColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor.withOpacity(0.5)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: textColor),
        ),
        iconColor: textColor,
        prefixIconColor: textColor,
      ),
      iconTheme: const IconThemeData(color: textColor),
      cardColor: backgroundColor,
      dividerColor: textColor.withOpacity(0.2),
      listTileTheme: ListTileThemeData(
        iconColor: textColor,
        textColor: textColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundColor,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: textColor),
      ),
    );
    return MaterialApp.router(
      title: 'Metanoia',
      theme: theme,
      routerConfig: createRouter(),
    );
  }
}
