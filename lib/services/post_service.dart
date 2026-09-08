import '../models/post.dart';
import 'api_service.dart';

// Same getPosts pagination and JSON mapping as the lab, with shared HTTP handling.
class PostService {
  final ApiService api;
  PostService({ApiService? api}) : api = api ?? ApiService();
  Future<List<Post>> getPosts({int limit = 30, int skip = 0}) async {
    final data = await api.request('/posts?limit=$limit&skip=$skip');
    return (data['posts'] as List).map((p) => Post.fromJson(p)).toList();
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    final data = await api.request('/posts/user/$userId?limit=0');
    return (data['posts'] as List).map((p) => Post.fromJson(p)).toList();
  }
}
