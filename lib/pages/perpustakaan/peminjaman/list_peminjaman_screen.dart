import 'package:api_flutter/services/buku_service.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/peminjaman_model.dart';
import 'package:api_flutter/services/peminjaman_service.dart';
import 'package:api_flutter/pages/perpustakaan/peminjaman/detail_peminjaman_screen.dart';
import 'package:api_flutter/pages/perpustakaan/peminjaman/create_peminjaman_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPeminjamen extends StatefulWidget {
  const ListPeminjamen({super.key});

  @override
  State<ListPeminjamen> createState() => _ListPeminjamenState();
}

class _ListPeminjamenState extends State<ListPeminjamen> {
  Future<PeminjamenModel>? _futurePeminjamen;
  int? _userId;
  String? _userNama;
  List<dynamic>? _listBuku;

  @override
  void initState() {
    super.initState();
    _initData(); // Pastikan urut: ambil user -> ambil buku -> ambil peminjaman
  }

  Future<void> _initData() async {
    await _loadUserData();
    await _loadBukuList();

    // Setelah data user ada, baru load daftar peminjaman
    setState(() {
      _futurePeminjamen = PeminjamenService.listPeminjamen();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id'); // pastikan key sama seperti di AuthService
      _userNama = prefs.getString('user_name');
    });

    print('User ID dari SharedPreferences: $_userId');
    print('User Name dari SharedPreferences: $_userNama');
  }

  Future<void> _loadBukuList() async {
    final bukuModel = await BukuService.listBuku();
    setState(() {
      _listBuku = bukuModel.data ?? [];
    });
  }

  void _refreshPeminjamen() {
    setState(() {
      _futurePeminjamen = PeminjamenService.listPeminjamen();
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final d = date is DateTime ? date : DateTime.parse(date.toString());
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Peminjaman'),
        actions: [
          IconButton(
              onPressed: _refreshPeminjamen, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePeminjamen()),
              );
              if (result == true) _refreshPeminjamen();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _futurePeminjamen == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<PeminjamenModel>(
              future: _futurePeminjamen,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final peminjamenList = snapshot.data?.data ?? [];
                if (peminjamenList.isEmpty) {
                  return const Center(child: Text('Tidak ada peminjaman'));
                }

                return ListView.builder(
                  itemCount: peminjamenList.length,
                  itemBuilder: (context, index) {
                    final peminjamen = peminjamenList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailPeminjamen(peminjamen: peminjamen)),
                          );
                          if (result == true) _refreshPeminjamen();
                        },
                        leading: const Icon(Icons.assignment,
                            size: 40, color: Colors.blue),
                        title: Text(
                          'User ID: ${peminjamen.userId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Buku ID: ${peminjamen.bukuId}'),
                            Text(
                                'Tanggal Pinjam: ${_formatDate(peminjamen.tanggalPinjam)}'),
                            Text('Tenggat: ${_formatDate(peminjamen.tenggat)}'),
                            if (peminjamen.tanggalPengembalian != null)
                              Text(
                                  'Pengembalian: ${_formatDate(peminjamen.tanggalPengembalian)}'),
                            Text('Status: ${peminjamen.status ?? '-'}'),
                          ],
                        ),
                        trailing: Text('#${peminjamen.id}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
