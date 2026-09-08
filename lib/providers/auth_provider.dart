import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final UserService service;
  User? user;
  bool ready = false;
  String? startupError;
  AuthProvider(this.prefs, {UserService? service})
    : service = service ?? UserService();
  Future<void> restore() async {
    startupError = null;
    try {
      final raw = prefs.getString('session');
      if (raw != null) {
        var data = jsonDecode(raw) as Map<String, dynamic>;
        try {
          await service.me(data['accessToken']);
        } on ApiException catch (e) {
          if (e.status != 401 && e.status != 403) rethrow;
          data = {...data, ...await service.refresh(data['refreshToken'])};
          await prefs.setString('session', jsonEncode(data));
        }
        user = User.fromJson(data);
      }
    } on ApiException catch (e) {
      if (e.status == 401 || e.status == 403) {
        await prefs.remove('session');
      } else {
        startupError = e.message;
      }
    } catch (_) {
      await prefs.remove('session');
    }
    ready = true;
    notifyListeners();
  }

  Future<void> login(String name, String password) async {
    final data = await service.login(name, password);
    final parsed = User.fromJson(data);
    // Store only identity and tokens, never the password.
    await prefs.setString(
      'session',
      jsonEncode({
        ...parsed.toJson(),
        'accessToken': data['accessToken'],
        'refreshToken': data['refreshToken'],
      }),
    );
    user = parsed;
    notifyListeners();
  }

  Future<void> signOut() async {
    await prefs.remove('session');
    user = null;
    startupError = null;
    notifyListeners();
  }
}
