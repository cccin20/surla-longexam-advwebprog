import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService api;
  UserService({ApiService? api}) : api = api ?? ApiService();
  Future<Map<String, dynamic>> login(String username, String password) =>
      api.request(
        '/auth/login',
        body: {'username': username, 'password': password, 'expiresInMins': 60},
      );
  Future<Map<String, dynamic>> me(String token) =>
      api.request('/auth/me', token: token);
  Future<Map<String, dynamic>> refresh(String token) =>
      api.request('/auth/refresh', body: {'refreshToken': token});
  Future<Map<int, User>> users() async {
    final data = await api.request(
      '/users?limit=0&select=id,username,firstName,lastName,email,image',
    );
    return {for (final j in data['users']) j['id'] as int: User.fromJson(j)};
  }
}
