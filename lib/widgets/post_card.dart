import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../providers/social_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/detail_screen.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final User? author;
  final bool detail;
  const PostCard({
    super.key,
    required this.post,
    this.author,
    this.detail = false,
  });
  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();
    final liked = social.liked(post.id);
    final compact = context.watch<ThemeProvider>().compact;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(url: author?.image),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author?.name ?? 'User ${post.userId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Public post', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.public, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              post.body,
              maxLines: compact && !detail ? 3 : null,
              overflow: compact && !detail ? TextOverflow.ellipsis : null,
              style: const TextStyle(height: 1.5),
            ),
            if (!compact || detail)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final tag in post.tags)
                      Text(
                        '#$tag',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text('${post.likes + (liked ? 1 : 0)} likes'),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      try {
                        await social.toggleLike(post.id);
                      } catch (_) {
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not save your like.'),
                            ),
                          );
                      }
                    },
                    icon: Icon(
                      liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    ),
                    label: Text(liked ? 'Liked' : 'Like'),
                  ),
                ),
                if (!detail)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: social,
                            child: DetailScreen(post: post, author: author),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Comments'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
