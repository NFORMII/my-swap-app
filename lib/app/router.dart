import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth screens
import 'package:my_book_swap_app/presentation/auth/login_screen.dart';
import 'package:my_book_swap_app/presentation/auth/signup_screen.dart';
import 'package:my_book_swap_app/presentation/auth/verify_email_screen.dart';
import 'package:my_book_swap_app/presentation/browse/browse_listings_screen.dart';

// Chat screens
import 'package:my_book_swap_app/presentation/chats/chat_list_screen.dart';
import 'package:my_book_swap_app/presentation/chats/chat_detail_screen.dart';

// Auth controller (for logout)
import 'package:my_book_swap_app/state/auth_providers.dart';

// Book and listing screens
// import 'package:my_book_swap_app/presentation/browse/browse_listings_screen.dart';
import 'package:my_book_swap_app/presentation/listings/my_listings_screen.dart';

/// Signal if Firebase initialized successfully (set in main.dart)
final firebaseReadyProvider = Provider<bool>((_) => false);

/// Centralized GoRouter with authentication guards and navigation structure.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      // 1️⃣ Not signed in → go to login (unless signing up)
      if (user == null && state.matchedLocation != '/signup') {
        return '/login';
      }

      // 2️⃣ Signed in but not verified → go to verify
      if (user != null && !user.emailVerified) {
        return '/verify';
      }

      // 3️⃣ Signed in and verified → block access to auth screens
      if (user != null &&
          user.emailVerified &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup' ||
              state.matchedLocation == '/verify')) {
        return '/';
      }

      return null; // no redirect
    },
    routes: [
      // Home route (with bottom navigation)
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: _HomeScaffold()),
      ),

      // Auth routes
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/verify', builder: (_, __) => const VerifyEmailScreen()),

      // Chat routes
      GoRoute(
        path: '/chats',
        name: 'chatList',
        builder: (_, __) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chats/:id',
        name: 'chatDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatDetailScreen(chatId: id);
        },
      ),
    ],
  );
});

/// Root scaffold containing the bottom navigation + main pages
class _HomeScaffold extends StatefulWidget {
  const _HomeScaffold();

  @override
  State<_HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<_HomeScaffold> {
  int _index = 0;

  final _pages = const [
    BrowseListingsScreen(), // ✅ from your listings module
    MyListingsScreen(),     // ✅ from your listings module
    ChatListScreen(),       // ✅ live chat list
    _SettingsPage(),        // ✅ settings with logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'My Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// ✅ SettingsPage — includes logout and Firebase status
class _SettingsPage extends ConsumerWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final authController = ref.watch(authControllerProvider.notifier);

    return _SectionScaffold(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Profile'),
              subtitle: const Text('Logged-in user details coming soon'),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Notification reminders'),
            subtitle: const Text('Simulated locally'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Email updates'),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(
                firebaseReady ? Icons.check_circle : Icons.error_outline,
                color: firebaseReady ? Colors.green : null,
              ),
              title: Text(firebaseReady
                  ? 'Firebase: Connected'
                  : 'Firebase: Not initialized'),
              subtitle: Text(firebaseReady
                  ? 'All systems operational!'
                  : 'Run flutterfire configure and restart the app.'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () async {
                await authController.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ------- Shared UI helpers -------
class _SectionScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionScaffold({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}



















// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// // Auth screens
// import 'package:my_book_swap_app/presentation/auth/login_screen.dart';
// import 'package:my_book_swap_app/presentation/auth/signup_screen.dart';
// import 'package:my_book_swap_app/presentation/auth/verify_email_screen.dart';
// import 'package:my_book_swap_app/presentation/chats/chat_detail_screen.dart';
// import 'package:my_book_swap_app/presentation/chats/chat_list_screen.dart';

// // Auth controller (for logout)
// import 'package:my_book_swap_app/state/auth_providers.dart';

// /// Signal if Firebase initialized successfully (set in main.dart)
// final firebaseReadyProvider = Provider<bool>((_) => false);

// /// Centralized GoRouter with authentication guards and navigation structure.
// final appRouterProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/login',
//     redirect: (context, state) {
//       final user = FirebaseAuth.instance.currentUser;

//       // 1️⃣ Not signed in → go to login
//       if (user == null && state.matchedLocation != '/signup') {
//         return '/login';
//       }

//       // 2️⃣ Signed in but not verified → go to verify
//       if (user != null && !user.emailVerified) {
//         return '/verify';
//       }

//       // 3️⃣ Signed in and verified → block access to login/signup/verify
//       if (user != null &&
//           user.emailVerified &&
//           (state.matchedLocation == '/login' ||
//               state.matchedLocation == '/signup' ||
//               state.matchedLocation == '/verify')) {
//         return '/';
//       }

//       return null; // no redirect
//     },
//     routes: [
//       GoRoute(
//         path: '/',
//         name: 'home',
//         pageBuilder: (context, state) =>
//             const NoTransitionPage(child: _HomeScaffold()),
//       ),
//       GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
//       GoRoute(
//         path: '/chats',
//         name: 'chatList',
//         builder: (_, __) => const ChatListScreen(),
//       ),
//             GoRoute(
//         path: '/chats/:id',
//         name: 'chatDetail',
//         builder: (context, state) {
//           final id = state.pathParameters['id']!;
//           return ChatDetailScreen(chatId: id);
//         },
//       ),
//       GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
//       GoRoute(path: '/verify', builder: (_, __) => const VerifyEmailScreen()),
//       GoRoute(
//         path: '/chats/:id',
//         name: 'chatDetail',
//         pageBuilder: (context, state) {
//           final id = state.pathParameters['id']!;
//           return MaterialPage(child: _ChatDetailPage(chatId: id));
//         },
//       ),
//     ],
//   );
// });

// /// Root scaffold containing the bottom navigation + main pages
// class _HomeScaffold extends StatefulWidget {
//   const _HomeScaffold();

//   @override
//   State<_HomeScaffold> createState() => _HomeScaffoldState();
// }

// class _HomeScaffoldState extends State<_HomeScaffold> {
//   int _index = 0;

//   final _pages = const [
//     _BrowsePage(),
//     _MyListingsPage(),
//     _ChatsPage(),
//     _SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: IndexedStack(index: _index, children: _pages),
//       ),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _index,
//         onDestinationSelected: (i) => setState(() => _index = i),
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.storefront_outlined),
//             selectedIcon: Icon(Icons.storefront),
//             label: 'Browse',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.library_books_outlined),
//             selectedIcon: Icon(Icons.library_books),
//             label: 'My Listings',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.chat_bubble_outline),
//             selectedIcon: Icon(Icons.chat_bubble),
//             label: 'Chats',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.settings_outlined),
//             selectedIcon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// ------- Placeholder Screens (UI-only for now) -------

// class _BrowsePage extends StatelessWidget {
//   const _BrowsePage();

//   @override
//   Widget build(BuildContext context) {
//     return const _SectionScaffold(
//       title: 'Browse Listings',
//       child: _EmptyHint(
//         icon: Icons.menu_book,
//         title: 'No listings yet',
//         subtitle:
//             'Once Firebase Firestore is connected, listings will appear here in real time.',
//       ),
//     );
//   }
// }

// class _MyListingsPage extends StatelessWidget {
//   const _MyListingsPage();

//   @override
//   Widget build(BuildContext context) {
//     return const _SectionScaffold(
//       title: 'My Listings',
//       child: _EmptyHint(
//         icon: Icons.library_add,
//         title: 'Create your first listing',
//         subtitle: 'In Step 3, you’ll be able to post, edit, and delete books.',
//       ),
//     );
//   }
// }

// class _ChatsPage extends StatelessWidget {
//   const _ChatsPage();

//   @override
//   Widget build(BuildContext context) {
//     return const _SectionScaffold(
//       title: 'Chats',
//       child: _EmptyHint(
//         icon: Icons.forum_outlined,
//         title: 'No chats yet',
//         subtitle: 'Chats appear after swap offers (Step 5).',
//       ),
//     );
//   }
// }

// /// ✅ Updated SettingsPage — includes logout button now
// class _SettingsPage extends ConsumerWidget {
//   const _SettingsPage();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final firebaseReady = ref.watch(firebaseReadyProvider);
//     final authController = ref.watch(authControllerProvider.notifier);

//     return _SectionScaffold(
//       title: 'Settings',
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: 8),
//           Card(
//             child: ListTile(
//               leading: const CircleAvatar(child: Icon(Icons.person)),
//               title: const Text('Profile'),
//               subtitle: const Text('Logged-in user details coming soon'),
//             ),
//           ),
//           const SizedBox(height: 12),
//           SwitchListTile(
//             value: true,
//             onChanged: (_) {},
//             title: const Text('Notification reminders'),
//             subtitle: const Text('Simulated locally'),
//           ),
//           SwitchListTile(
//             value: true,
//             onChanged: (_) {},
//             title: const Text('Email updates'),
//           ),
//           const SizedBox(height: 20),
//           Card(
//             child: ListTile(
//               leading: Icon(
//                 firebaseReady ? Icons.check_circle : Icons.error_outline,
//                 color: firebaseReady ? Colors.green : null,
//               ),
//               title: Text(firebaseReady
//                   ? 'Firebase: Connected'
//                   : 'Firebase: Not initialized'),
//               subtitle: Text(firebaseReady
//                   ? 'All systems operational!'
//                   : 'Run flutterfire configure and restart the app.'),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Center(
//             child: ElevatedButton.icon(
//               icon: const Icon(Icons.logout),
//               label: const Text('Log Out'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               ),
//               onPressed: () async {
//                 await authController.signOut();
//                 if (context.mounted) context.go('/login');
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Chat detail placeholder
// class _ChatDetailPage extends StatelessWidget {
//   final String chatId;
//   const _ChatDetailPage({required this.chatId});

//   @override
//   Widget build(BuildContext context) {
//     return _SectionScaffold(
//       title: 'Chat #$chatId',
//       child: const _EmptyHint(
//         icon: Icons.chat_bubble_outline,
//         title: 'Chat detail placeholder',
//         subtitle: 'Messaging will be implemented in Step 5.',
//       ),
//     );
//   }
// }

// /// ------- Shared UI helpers -------
// class _SectionScaffold extends StatelessWidget {
//   final String title;
//   final Widget child;
//   const _SectionScaffold({required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: child,
//       ),
//     );
//   }
// }

// class _EmptyHint extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   const _EmptyHint({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 64),
//           const SizedBox(height: 12),
//           Text(title, style: theme.textTheme.titleLarge),
//           const SizedBox(height: 6),
//           Text(
//             subtitle,
//             style: theme.textTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
