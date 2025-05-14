import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.48:8080/api/auth';
  // final String baseUrl = 'http://10.0.2.2:8080/api/auth';
  static const String USER_ID_KEY = 'userId';

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userId = data['uid'];
      await _saveUserId(userId);
      return userId;
    } else {
      return null;
    }
  }

  Future<String?> signup(String username, String email, String password) async {
    try {
      final response = await http.post(
        // Uri.parse('http://10.0.2.2:8080/api/auth/register'),
        Uri.parse('http://192.168.1.48:8080/api/auth/register'),
        body: jsonEncode(
            {'name': username, 'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['uid'];
      } else {
        print('Lỗi từ server: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi trong signup: $e');
      return null;
    }
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_ID_KEY, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ID_KEY);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_ID_KEY);
  }

  Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null;
  }
}
