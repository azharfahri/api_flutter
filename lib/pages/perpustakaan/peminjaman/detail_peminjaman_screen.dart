import 'package:api_flutter/pages/perpustakaan/peminjaman/edit_peminjamen_screen.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/peminjaman_model.dart';
//import 'package:api_flutter/pages/perpustakaan/peminjaman/edit_peminjaman.dart';
import 'package:api_flutter/services/peminjaman_service.dart';

class DetailPeminjamen extends StatefulWidget {
  final DataPeminjaman peminjamen;

  const DetailPeminjamen({Key? key, required this.peminjamen}) : super(key: key);

  @override
  State<DetailPeminjamen> createState() => _PeminjamenDetailState();
}

class _PeminjamenDetailState extends State<DetailPeminjamen> {
  bool _isLoading = false;

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _deletePeminjamen() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Peminjaman"),
        content: Text(
            'Yakin ingin menghapus peminjaman dengan ID #${widget.peminjamen.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success =
          await PeminjamenService.deletePeminjamen(widget.peminjamen.id!);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Peminjaman berhasil dihapus")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Gagal menghapus peminjaman"),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.peminjamen;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Peminjaman"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deletePeminjamen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${p.id}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("User ID: ${p.userId}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Buku ID: ${p.bukuId}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Tanggal Pinjam: ${_formatDate(p.tanggalPinjam)}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Tenggat: ${_formatDate(p.tenggat)}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Tanggal Pengembalian: ${_formatDate(p.tanggalPengembalian)}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Status: ${p.status ?? '-'}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditPeminjamen(peminjamen: p),
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