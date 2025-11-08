import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;

  Future<void> _refreshVerificationStatus() async {
    setState(() => _checking = true);

    final user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // 🔁 refresh the current user
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && refreshedUser.emailVerified) {
      // ✅ verified → go home
      if (mounted) context.go('/');
    } else {
      // ❌ not yet verified
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not verified yet. Try again later.')),
        );
      }
    }

    setState(() => _checking = false);
  }

  Future<void> _resendEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent again!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Check your inbox for a verification email.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checking ? null : _resendEmail,
                child: const Text('Resend Email'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _checking ? null : _refreshVerificationStatus,
                child: _checking
                    ? const CircularProgressIndicator()
                    : const Text('Refresh Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

























// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../state/auth_providers.dart';

// class VerifyEmailScreen extends ConsumerWidget {
//   const VerifyEmailScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final repo = ref.read(authRepoProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Email')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             const Icon(Icons.mark_email_read, size: 64),
//             const SizedBox(height: 12),
//             const Text(
//               'Check your inbox for a verification email.',
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () async => await repo.sendEmailVerification(),
//               child: const Text('Resend Email'),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () async {
//                 await FirebaseAuth.instance.currentUser?.reload();
//               },
//               child: const Text('Refresh Status'),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }
