import 'dart:convert';
import 'dart:io';
import 'package:api_flutter/models/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  static const String postUrl = 'http://127.0.0.1:8000/api/posts/';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<PostModel> listPosts() async {
    final token = await getToken();
    final response = await http.get(Uri.parse(postUrl),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PostModel.fromJson(json);
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
