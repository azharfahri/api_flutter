import 'dart:convert';
import 'dart:io';
import 'package:api_flutter/models/peminjaman_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PeminjamenService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/peminjamen';
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET semua peminjaman
  static Future<PeminjamenModel> listPeminjamen() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return peminjamenModelFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data peminjaman');
    }
  }

  // GET detail peminjaman
  static Future<DataPeminjaman> showPeminjamen(int id) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DataPeminjaman.fromJson(data['data']);
    } else {
      throw Exception('Gagal memuat detail peminjaman');
    }
  }

  // CREATE peminjaman
  static Future<Map<String, dynamic>> createPeminjamen(
    int userId,
    int bukuId,
    DateTime tanggalPinjam,
    DateTime tenggat, {
    int stokDipinjam = 1,
    String status = 'dipinjam',
  }) async {
    final token = await getToken();
    final uri = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();
    request.fields['buku_id'] = bukuId.toString();
    request.fields['tanggal_pinjam'] = dateFormat.format(tanggalPinjam);
    request.fields['tenggat'] = dateFormat.format(tenggat);
    request.fields['status'] = status;
    request.fields['stok_dipinjam'] = stokDipinjam.toString();

    request.headers['Authorization'] = 'Bearer $token';
    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(respStr);
    } else {
      return {
        "success": false,
        "message": "Gagal membuat peminjaman: ${response.statusCode}",
      };
    }
  }

  // UPDATE peminjaman
  static Future<bool> updatePeminjamen(
    int id,
    int userId,
    int bukuId,
    DateTime tanggalPinjam,
    DateTime tenggat,
    int stokDipinjam,
    DateTime? tanggalPengembalian,
    String status,
  ) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$id?_method=PUT'),
    );

    request.fields['user_id'] = userId.toString();
    request.fields['buku_id'] = bukuId.toString();
    request.fields['tanggal_pinjam'] = dateFormat.format(tanggalPinjam);
    request.fields['tenggat'] = dateFormat.format(tenggat);
    request.fields['status'] = status;
    request.fields['stok_dipinjam'] = stokDipinjam.toString();

    if (tanggalPengembalian != null) {
      request.fields['tanggal_pengembalian'] =
          dateFormat.format(tanggalPengembalian);
    }

    request.headers['Authorization'] = 'Bearer $token';
    final response = await request.send();
    return response.statusCode == 200;
  }

  // DELETE peminjaman
  static Future<bool> deletePeminjamen(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}