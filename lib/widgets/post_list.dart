import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import 'post_card.dart';

class PostList extends StatefulWidget {
  final int? userId;
  final Widget? header;
  const PostList({super.key, this.userId, this.header});
  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  List<Post> posts = [];
  Map<int, User> users = {};
  bool loading = true, more = false, hasMore = true;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool append = false}) async {
    setState(() {
      error = null;
      if (append) {
        more = true;
      } else {
        loading = true;
      }
    });
    try {
      final results = await Future.wait([
        widget.userId == null
            ? PostService().getPosts(skip: append ? posts.length : 0)
            : PostService().getPostsByUser(widget.userId!),
        users.isEmpty ? UserService().users() : Future.value(users),
      ]);
      if (!mounted) return;
      final next = results[0] as List<Post>;
      setState(() {
        posts = append ? [...posts, ...next] : next;
        users = results[1] as Map<int, User>;
        hasMore = widget.userId == null && next.length == 30;
      });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted)
        setState(() {
          loading = false;
          more = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => load(),
    child: ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.header != null) widget.header!,
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  for (final post in posts)
                    PostCard(post: post, author: users[post.userId]),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(error!),
                          TextButton(
                            onPressed: () => load(append: posts.isNotEmpty),
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  if (posts.isEmpty && error == null)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No posts yet.', textAlign: TextAlign.center),
                    ),
                  if (hasMore && error == null)
                    TextButton(
                      onPressed: more ? null : () => load(append: true),
                      child: Text(more ? 'Loading…' : 'Load more posts'),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
