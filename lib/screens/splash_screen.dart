import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.facebook,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Surla Social',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (auth.startupError == null)
              const CircularProgressIndicator()
            else ...[
              Text(auth.startupError!, textAlign: TextAlign.center),
              TextButton(
                onPressed: auth.restore,
                child: const Text('Retry session check'),
              ),
              TextButton(
                onPressed: auth.signOut,
                child: const Text('Go to sign in'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
