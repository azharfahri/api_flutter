import 'package:api_flutter/pages/perpustakaan/buku/edit_buku_screen.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/buku_model.dart';
import 'package:api_flutter/services/buku_service.dart';

class BukuDetail extends StatefulWidget {
  final DataBuku buku;

  const BukuDetail({Key? key, required this.buku}) : super(key: key);

  @override
  State<BukuDetail> createState() => _BukuDetailState();
}

class _BukuDetailState extends State<BukuDetail> {
  bool _isLoading = false;

  // ====== tambahan: biar bisa nampilin nama kategori dari kategoriId ======
  String? _kategoriNama;
  bool _loadingKategori = true;

  @override
  void initState() {
    super.initState();
    _fetchKategoriNama();
  }

  Future<void> _fetchKategoriNama() async {
    try {
      final list = await BukuService.getKategori(); // [{id:1, nama:"Fiksi"}, ...]
      final match = list.firstWhere(
        (e) => e['id'] == widget.buku.kategoriId,
        orElse: () => {},
      );
      setState(() {
        _kategoriNama = match.isNotEmpty
            ? (match['nama'] ?? match['nama_kategori'] ?? match['name'] ?? '')
            : null;
        _loadingKategori = false;
      });
    } catch (e) {
      setState(() {
        _kategoriNama = null;
        _loadingKategori = false;
      });
    }
  }
  // =======================================================================

  Future<void> _deleteBuku() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Buku"),
        content: Text('Yakin ingin menghapus buku "${widget.buku.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await BukuService.deleteBuku(widget.buku.id!);
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Buku berhasil dihapus")),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteBuku,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ================= COVER BUKU =================
            if (widget.buku.cover != null && widget.buku.cover!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "http://127.0.0.1:8000/storage/${widget.buku.cover}",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            const SizedBox(height: 16),
            // =================================================

            Text(
              widget.buku.judul ?? 'Tidak ada judul buku',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Penulis: ${widget.buku.penulis ?? '-'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Penerbit: ${widget.buku.penerbit ?? '-'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tahun Terbit: ${widget.buku.tahunTerbit ?? '-'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _loadingKategori
                  ? 'Kategori: ...'
                  : 'Kategori: ${_kategoriNama?.isNotEmpty == true ? _kategoriNama : (widget.buku.kategoriId?.toString() ?? "-")}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (widget.buku.createdAt != null)
              Text(
                'Dibuat: ${_formatDate(widget.buku.createdAt!)}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditBuku(buku: widget.buku),
            ),
          );
          if (result == true && mounted) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
