import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ✅ add this import

import 'app/router.dart';
import 'app/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;
  try {
    // ✅ Proper initialization using FlutterFire CLI
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    log('✅ Firebase initialized successfully');
  } catch (e, st) {
    log(
      '❌ Firebase failed to initialize (UI will run in stub mode). Error: $e',
      stackTrace: st,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseReadyProvider.overrideWithValue(firebaseReady),
      ],
      child: const BookSwapApp(),
    ),
  );
}

class BookSwapApp extends ConsumerWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BookSwap',
      routerConfig: router,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
    );
  }
}












// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'app/router.dart';
// import 'app/theme.dart';

// /// Entry point.
// /// - Initializes Firebase (safe try/catch so the app still boots if not configured yet)
// /// - Wraps in Riverpod's ProviderScope
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   bool firebaseReady = false;
//   try {
//     // If you've run `flutterfire configure`, this will succeed.
//     await Firebase.initializeApp();
//     firebaseReady = true;
//   } catch (e, st) {
//     // We intentionally do not crash so you can verify the UI first.
//     // Once Firebase is configured, this path won't execute.
//     log('Firebase failed to initialize (UI will run in stub mode). '
//         'Configure with flutterfire. Error: $e',
//         stackTrace: st);
//   }

//   runApp(ProviderScope(
//     overrides: [
//       firebaseReadyProvider.overrideWithValue(firebaseReady),
//     ],
//     child: const BookSwapApp(),
//   ));
// }

// class BookSwapApp extends ConsumerWidget {
//   const BookSwapApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(appRouterProvider);
//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       title: 'BookSwap',
//       routerConfig: router,
//       theme: buildLightTheme(),
//       darkTheme: buildDarkTheme(),
//       themeMode: ThemeMode.system,
//     );
//   }
// }
