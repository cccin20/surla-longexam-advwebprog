import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class SocialProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final int userId;
  final CommentService service;
  SocialProvider(this.prefs, this.userId, {CommentService? service})
    : service = service ?? CommentService();
  String get key => 'social_$userId';
  Map<String, dynamic> get saved {
    try {
      return jsonDecode(prefs.getString(key) ?? '{}') as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  bool liked(int id) => (saved['likes'] as List? ?? []).contains(id);
  Future<void> toggleLike(int id) async {
    final data = saved;
    final likes = List<int>.from(data['likes'] ?? []);
    likes.contains(id) ? likes.remove(id) : likes.add(id);
    data['likes'] = likes;
    await prefs.setString(key, jsonEncode(data));
    notifyListeners();
  }

  List<Comment> localComments(int id) => (saved['comments'] as List? ?? [])
      .map((j) => Comment.fromJson(j))
      .where((c) => c.postId == id)
      .toList();
  Future<void> addComment(int id, String body) async {
    final comment = await service.addComment(id, userId, body.trim());
    final data = saved;
    data['comments'] = [...data['comments'] as List? ?? [], comment.toJson()];
    await prefs.setString(key, jsonEncode(data));
    notifyListeners();
  }
}
