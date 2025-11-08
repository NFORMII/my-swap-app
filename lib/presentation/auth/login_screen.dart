import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authControllerProvider.notifier);
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => email = v.trim(),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Enter a valid password' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state is AsyncLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        try {
                          await controller.signIn(email, password);

                          final user =
                              FirebaseAuth.instance.currentUser; // check user
                          if (user != null && !user.emailVerified) {
                            // Unverified → go to verify
                            if (context.mounted) context.go('/verify');
                          } else if (user != null && user.emailVerified) {
                            // Verified → go home
                            if (context.mounted) context.go('/');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Login failed: $e')),
                            );
                          }
                        }
                      },
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/signup'), // ✅ fixed navigation
                  child: const Text("Don't have an account? Sign up"),
                ),
              ),
              if (state is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
