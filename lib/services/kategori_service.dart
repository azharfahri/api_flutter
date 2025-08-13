import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api_flutter/models/kategori_model.dart';

class KategoriService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/kategoris';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get all kategori
  static Future<KategoriModel> listKategoris() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return KategoriModel.fromJson(json);
    } else {
      throw Exception('Failed to load kategori');
    }
  }

  // Create kategori
  static Future<bool> createKategori(String nama) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({'nama': nama}),
    );
    return response.statusCode == 201;
  }

  // Update kategori
  static Future<bool> updateKategori(int id, String nama) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({'nama': nama}),
    );
    return response.statusCode == 200;
  }

  // Delete kategori
  static Future<bool> deleteKategori(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
