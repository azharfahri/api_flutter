import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
      headers: {'Accept': 'application/json'},
    );

    print('Login Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);

      // Kalau API langsung kirim data user
      if (data['user'] != null) {
        if (data['user']['id'] != null) {
          await prefs.setInt('user_id', data['user']['id']);
        }
        if (data['user']['name'] != null) {
          await prefs.setString('user_name', data['user']['name']);
        }
      } else {
        // API tidak kirim data user → ambil profil setelah login
        final profile = await getProfile();
        if (profile != null) {
          if (profile['id'] != null) {
            await prefs.setInt('user_id', profile['id']);
          }
          if (profile['name'] != null) {
            await prefs.setString('user_name', profile['name']);
          }
        }
      }

      // Debug
      print("User ID dari SharedPreferences: ${prefs.getInt('user_id')}");
      print("User Name dari SharedPreferences: ${prefs.getString('user_name')}");

      return true;
    } else {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'name': name, 'email': email, 'password': password},
    );
    return response.statusCode == 201;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      print("Profile Response: ${response.body}");
      return jsonDecode(response.body);
    } else {
      print("Gagal ambil profil: ${response.statusCode}");
      return null;
    }
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }
}
