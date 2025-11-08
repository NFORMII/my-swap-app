import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authControllerProvider.notifier);
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => email = v,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) => v == null || v.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state is AsyncLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        await controller.signUp(email, password);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Verification email sent! Please check your inbox.'),
                            ),
                          );
                          context.go('/verify'); // ✅ GoRouter navigation
                        }
                      },
                child: const Text('Sign Up'),
              ),
              if (state is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
