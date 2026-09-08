import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final name = TextEditingController(), password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false, hidden = true;
  String? error;
  @override
  void dispose() {
    name.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await context.read<AuthProvider>().login(name.text.trim(), password.text);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.facebook,
                  size: 76,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Connect with your world.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome to Surla Social',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: name,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter your username'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  enabled: !busy,
                  obscureText: hidden,
                  onFieldSubmitted: (_) {
                    if (!busy) submit();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: hidden ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => hidden = !hidden),
                      icon: Icon(
                        hidden ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your password' : null,
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: busy ? null : submit,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(busy ? 'Signing in…' : 'Log in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
