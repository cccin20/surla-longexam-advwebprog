import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surla_longexam/main.dart';
import 'package:surla_longexam/models/post.dart';
import 'package:surla_longexam/providers/auth_provider.dart';
import 'package:surla_longexam/providers/social_provider.dart';
import 'package:surla_longexam/providers/theme_provider.dart';
import 'package:surla_longexam/services/api_service.dart';
import 'package:surla_longexam/services/user_service.dart';
import 'package:surla_longexam/services/post_service.dart';
import 'package:surla_longexam/services/comment_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Lab post supports both field formats and round trips', () {
    final p = Post.fromJson({
      'id': 3,
      'user_id': 7,
      'post_id': 2,
      'likes': 12,
      'dislikes': 1,
      'created_at': 'today',
    });
    expect(p.userId, 7);
    expect(p.postId, 2);
    expect(Post.fromJson(p.toJson()).likes, 12);
  });
  test(
    'Login persists identity, restores session and clears on sign out',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final api = ApiService(
        client: MockClient(
          (r) async => http.Response(
            jsonEncode({
              'id': 1,
              'username': 'emilys',
              'accessToken': 'a',
              'refreshToken': 'r',
            }),
            200,
          ),
        ),
      );
      final auth = AuthProvider(prefs, service: UserService(api: api));
      await auth.login('emilys', 'password');
      expect(auth.user!.id, 1);
      expect(prefs.getString('session'), isNot(contains('password')));
      final restored = AuthProvider(prefs, service: UserService(api: api));
      await restored.restore();
      expect(restored.user!.id, 1);
      await restored.signOut();
      expect(prefs.getString('session'), isNull);
    },
  );
  test('Expired session refreshes stored tokens', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'session',
      jsonEncode({
        'id': 1,
        'accessToken': 'expired',
        'refreshToken': 'refresh',
      }),
    );
    final api = ApiService(
      client: MockClient(
        (r) async => r.url.path == '/auth/me'
            ? http.Response('{"message":"Expired"}', 401)
            : http.Response(
                '{"accessToken":"new","refreshToken":"new-r"}',
                200,
              ),
      ),
    );
    final auth = AuthProvider(prefs, service: UserService(api: api));
    await auth.restore();
    expect(auth.user!.id, 1);
    expect(prefs.getString('session'), contains('new'));
  });
  test('Profile and comments request all records for correct IDs', () async {
    final paths = <String>[];
    final api = ApiService(
      client: MockClient((r) async {
        paths.add(r.url.toString());
        return http.Response(
          r.url.path.startsWith('/posts') ? '{"posts":[]}' : '{"comments":[]}',
          200,
        );
      }),
    );
    await PostService(api: api).getPostsByUser(7);
    await CommentService(api: api).getComments(42);
    expect(paths[0], endsWith('/posts/user/7?limit=0'));
    expect(paths[1], endsWith('/comments/post/42?limit=0'));
  });
  test('Likes toggle and comments persist separately per account', () async {
    final prefs = await SharedPreferences.getInstance();
    final api = ApiService(
      client: MockClient((r) async {
        final body = jsonDecode(r.body);
        return http.Response(
          jsonEncode({
            ...body,
            'id': 341,
            'user': {'fullName': 'Emily'},
          }),
          201,
        );
      }),
    );
    final social = SocialProvider(prefs, 1, service: CommentService(api: api));
    await social.toggleLike(3);
    expect(social.liked(3), true);
    await social.addComment(3, 'Hello');
    expect(SocialProvider(prefs, 1).localComments(3).single.body, 'Hello');
    expect(SocialProvider(prefs, 2).localComments(3), isEmpty);
    expect(SocialProvider(prefs, 2).liked(3), false);
    await social.toggleLike(3);
    expect(social.liked(3), false);
  });
  testWidgets('Signed out startup shows login and validates blank input', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthProvider(prefs);
    await auth.restore();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ],
        child: const LabApp(),
      ),
    );
    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
