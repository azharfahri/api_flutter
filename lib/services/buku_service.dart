import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:api_flutter/models/buku_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BukuService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/bukus';
  static const String kategoriUrl = 'http://127.0.0.1:8000/api/kategoris';

  // Ambil token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil daftar kategori
  static Future<List<Map<String, dynamic>>> getKategori() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(kategoriUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        return List<Map<String, dynamic>>.from(json['data']);
      }
      return [];
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  // GET semua buku
  static Future<BukuModel> listBuku() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BukuModel.fromJson(json);
    } else {
      throw Exception('Gagal memuat daftar buku');
    }
  }

  // GET detail buku by ID
  static Future<DataBuku?> showBuku(int id) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        return DataBuku.fromJson(json['data']);
      }
      return null;
    } else {
      throw Exception('Gagal memuat detail buku');
    }
  }

  // CREATE buku baru (tanpa kode_buku)
  static Future<bool> createBuku(
    String judul,
    String penulis,
    String penerbit,
    int tahunTerbit,
    int stok,
    int kategoriId,
    Uint8List? coverBytes,
    String? coverName,
  ) async {
    final token = await getToken();
    final uri = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['judul'] = judul;
    request.fields['penulis'] = penulis;
    request.fields['penerbit'] = penerbit;
    request.fields['tahun_terbit'] = tahunTerbit.toString();
    request.fields['stok'] = stok.toString();
    request.fields['kategori_id'] = kategoriId.toString();

    if (coverBytes != null && coverName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'cover',
          coverBytes,
          filename: coverName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();
    return response.statusCode == 201;
  }

  // UPDATE buku (tanpa kode_buku)
  static Future<bool> updateBuku(
    int id,
    String judul,
    String penulis,
    String penerbit,
    int tahunTerbit,
    int stok,
    int kategoriId,
    Uint8List? coverBytes,
    String? coverName,
  ) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$id?_method=PUT'),
    );

    request.fields['judul'] = judul;
    request.fields['penulis'] = penulis;
    request.fields['penerbit'] = penerbit;
    request.fields['tahun_terbit'] = tahunTerbit.toString();
    request.fields['stok'] = stok.toString();
    request.fields['kategori_id'] = kategoriId.toString();

    if (coverBytes != null && coverName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'cover',
          coverBytes,
          filename: coverName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();
    return response.statusCode == 200;
  }

  // DELETE buku
  static Future<bool> deleteBuku(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
