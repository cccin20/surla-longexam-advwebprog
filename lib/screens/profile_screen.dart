import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_list.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    return PostList(
      userId: user.id,
      header: Card(
        child: Column(
          children: [
            Container(
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1877f2), Color(0xff81b9ff)],
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.people_outline,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            UserAvatar(url: user.image, radius: 40),
            const SizedBox(height: 12),
            Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
            Text('@${user.username}'),
            Padding(padding: const EdgeInsets.all(16), child: Text(user.email)),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Your posts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
