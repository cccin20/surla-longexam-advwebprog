import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('Make your feed feel like you.'),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark mode'),
                        subtitle: const Text('Use a darker color palette'),
                        value: theme.dark,
                        onChanged: theme.setDark,
                      ),
                      SwitchListTile(
                        title: const Text('Compact feed'),
                        subtitle: const Text(
                          'Show shorter previews in your feed',
                        ),
                        value: theme.compact,
                        onChanged: theme.setCompact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await context.read<AuthProvider>().signOut();
                    } catch (_) {
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not sign out. Try again.'),
                          ),
                        );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
