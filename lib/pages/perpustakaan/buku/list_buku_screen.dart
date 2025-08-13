import 'package:api_flutter/pages/perpustakaan/buku/create_buku_screen.dart';
import 'package:api_flutter/pages/perpustakaan/buku/detail_buku_screen.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/buku_model.dart';
import 'package:api_flutter/services/buku_service.dart';

// import 'package:api_flutter/pages/perpustakaan/buku/create_buku.dart';

class ListBuku extends StatefulWidget {
  const ListBuku({super.key});

  @override
  State<ListBuku> createState() => _ListBukuState();
}

class _ListBukuState extends State<ListBuku> {
  late Future<BukuModel> _futureBuku;

  @override
  void initState() {
    super.initState();
    _futureBuku = BukuService.listBuku();
  }

  void _refreshBuku() {
    setState(() {
      _futureBuku = BukuService.listBuku();
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
        title: const Text('List Buku'),
        actions: [
          IconButton(onPressed: _refreshBuku, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateBuku()),
              );
              if (result == true) _refreshBuku();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<BukuModel>(
        future: _futureBuku,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bukuList = snapshot.data?.data ?? [];
          if (bukuList.isEmpty) {
            return const Center(child: Text('Tidak ada buku'));
          }

          return ListView.builder(
            itemCount: bukuList.length,
            itemBuilder: (context, index) {
              final buku = bukuList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BukuDetail(buku: buku)),
                    );
                    if (result == true) _refreshBuku();
                  },
                  leading: (buku.cover != null && buku.cover!.isNotEmpty)
                      ? Image.network(
                          'http://127.0.0.1:8000/storage/${buku.cover!}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.menu_book, size: 40),
                  title: Text(
                    buku.judul ?? 'Tanpa Judul',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (buku.tahunTerbit != null)
                        Text(
                          _formatDate(buku.tahunTerbit),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: Text('#${buku.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}