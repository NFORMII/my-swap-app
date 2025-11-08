import 'package:flutter/material.dart';

/// App-wide themes inspired by the navy + yellow look in your mockups.
ThemeData buildLightTheme() {
  const seed = Color(0xFF0D1630); // deep navy
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light)
      .copyWith(secondary: const Color(0xFFF5C243)); // warm yellow

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: scheme.secondary.withOpacity(.22),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(height: 1.3),
    ),
  );
}

ThemeData buildDarkTheme() {
  const seed = Color(0xFF0D1630);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)
      .copyWith(secondary: const Color(0xFFF5C243));

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: scheme.secondary.withOpacity(.28),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
