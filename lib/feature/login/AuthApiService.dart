
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String username, String password) async {
    const String url = 'https://dummyjson.com/auth/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('API Response: ${response.body}'); // Debugging

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('accessToken') && data['accessToken'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('accessToken', data['accessToken']);

          await prefs.setInt('userId', data['id']);
          await prefs.setString('username', data['username']);
          await prefs.setString('email', data['email']);
          await prefs.setString('firstName', data['firstName']);
          await prefs.setString('lastName', data['lastName']);
          await prefs.setString('image', data['image']);

          return data;
        } else {
          return {'error': 'accessToken not found in response'};
        }
      } else {
        return {'error': 'Invalid credentials'};
      }
    } catch (e) {
      return {'error': 'Login failed: $e'};
    }
  }
}