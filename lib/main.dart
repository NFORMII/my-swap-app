import 'package:flutter/material.dart';
import 'app.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (stubbed). Replace with real Firebase init when configured.
  await FirebaseService.initialize();
  runApp(const BookSwapApp());
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
