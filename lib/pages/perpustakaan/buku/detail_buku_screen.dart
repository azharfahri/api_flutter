import 'package:flutter/material.dart';
import 'package:api_flutter/models/buku_model.dart';
//import 'package:api_flutter/pages/perpustakaan/buku/edit_buku.dart';
import 'package:api_flutter/services/buku_service.dart';

class BukuDetail extends StatefulWidget {
  final DataBuku buku;

  const BukuDetail({Key? key, required this.buku}) : super(key: key);

  @override
  State<BukuDetail> createState() => _BukuDetailState();
}

class _BukuDetailState extends State<BukuDetail> {
  bool _isLoading = false;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.buku.judul ?? 'Tidak ada judul buku',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.buku.penulis != null)
              Text(
                'Penulis: ${widget.buku.penulis!}',
                style: const TextStyle(fontSize: 16),
              ),
            if (widget.buku.createdAt != null)
              Text(
                _formatDate(widget.buku.createdAt!),
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.edit),
      //   onPressed: () async {
      //     final result = await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (_) => EditBuku(buku: widget.buku),
      //       ),
      //     );
      //     if (result == true && mounted) {
      //       Navigator.pop(context, true);
      //     }
      //   },
      // ),
    );
  }
}