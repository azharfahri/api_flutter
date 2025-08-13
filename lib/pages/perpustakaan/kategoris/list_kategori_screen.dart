import 'package:api_flutter/pages/perpustakaan/kategoris/create_kategori_screen.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/kategori_model.dart';
import 'package:api_flutter/services/kategori_service.dart';


class ListKategori extends StatefulWidget {
  const ListKategori({super.key});

  @override
  State<ListKategori> createState() => _ListKategoriState();
}

class _ListKategoriState extends State<ListKategori> {
  late Future<KategoriModel> _futureKategori;

  @override
  void initState() {
    super.initState();
    _futureKategori = KategoriService.listKategoris();
  }

  void _refreshKategori() {
    setState(() {
      _futureKategori = KategoriService.listKategoris();
    });
  }

  Future<void> _hapusKategori(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin mau hapus kategori ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await KategoriService.deleteKategori(id);
      _refreshKategori();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Kategori'),
        actions: [
          IconButton(onPressed: _refreshKategori, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateKategori()),
              );
              if (result == true) _refreshKategori();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<KategoriModel>(
        future: _futureKategori,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final kategoriList = snapshot.data?.data ?? [];
          if (kategoriList.isEmpty) {
            return const Center(child: Text('Tidak ada kategori'));
          }

          return ListView.builder(
            itemCount: kategoriList.length,
            itemBuilder: (context, index) {
              final kategori = kategoriList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(kategori.nama ?? 'Tanpa Nama'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateKategori(
                                kategori: kategori,
                              ),
                            ),
                          );
                          if (result == true) _refreshKategori();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusKategori(kategori.id ?? 0),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
