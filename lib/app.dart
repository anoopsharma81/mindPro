import 'package:flutter/material.dart';
import 'router.dart';

class MetanoiaApp extends StatelessWidget {
  const MetanoiaApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: const Color(0xFF4F46E5),
      useMaterial3: true,
    );
    return MaterialApp.router(
      title: 'Metanoia',
      theme: theme,
      routerConfig: createRouter(),
    );
  }
}
