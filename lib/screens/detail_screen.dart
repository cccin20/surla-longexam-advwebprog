import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../providers/social_provider.dart';
import '../services/comment_service.dart';
import '../widgets/post_card.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  final User? author;
  const DetailScreen({super.key, required this.post, this.author});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final input = TextEditingController();
  late Future<List<Comment>> comments;
  bool sending = false;
  String? error;
  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    comments = CommentService().getComments(widget.post.id);
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (input.text.trim().isEmpty) return;
    setState(() {
      sending = true;
      error = null;
    });
    try {
      await context.read<SocialProvider>().addComment(
        widget.post.id,
        input.text,
      );
      input.clear();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = context.watch<SocialProvider>().localComments(widget.post.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Post & comments')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PostCard(post: widget.post, author: widget.author, detail: true),
              Text(
                'All comments',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Comment>>(
                future: comments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Column(
                      children: [
                        Text(snapshot.error.toString()),
                        TextButton(
                          onPressed: () => setState(reload),
                          child: const Text('Retry comments'),
                        ),
                      ],
                    );
                  final all = [...snapshot.data!, ...local];
                  return Column(
                    children: [
                      if (all.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No comments yet. Start the conversation.',
                          ),
                        ),
                      for (final c in all)
                        Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(c.body),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: input,
                enabled: !sending,
                maxLines: 3,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Write a comment',
                  border: OutlineInputBorder(),
                ),
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              FilledButton.icon(
                onPressed: sending ? null : send,
                icon: const Icon(Icons.send),
                label: Text(sending ? 'Posting…' : 'Post comment'),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Demo comments are saved on this device for your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
