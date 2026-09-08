import '../models/comment.dart';
import 'api_service.dart';

class CommentService {
  final ApiService api;
  CommentService({ApiService? api}) : api = api ?? ApiService();
  Future<List<Comment>> getComments(int postId) async {
    final data = await api.request('/comments/post/$postId?limit=0');
    return (data['comments'] as List).map((j) => Comment.fromJson(j)).toList();
  }

  Future<Comment> addComment(int postId, int userId, String body) async =>
      Comment.fromJson(
        await api.request(
          '/comments/add',
          body: {'postId': postId, 'userId': userId, 'body': body},
        ),
      );
}
