import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:api_flutter/models/buku_model.dart';
import 'package:api_flutter/services/buku_service.dart';
import 'package:image_picker/image_picker.dart';

class EditBuku extends StatefulWidget {
  final DataBuku buku;
  const EditBuku({Key? key, required this.buku}) : super(key: key);

  @override
  State<EditBuku> createState() => _EditBukuState();
}

class _EditBukuState extends State<EditBuku> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _penulisController;
  late TextEditingController _penerbitController;
  late TextEditingController _tahunTerbitController;
  late TextEditingController _stokController;

  Uint8List? _coverBytes;
  String? _coverName;

  List<Map<String, dynamic>> _kategoriList = [];
  int? _selectedKategoriId;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.buku.judul);
    _penulisController = TextEditingController(text: widget.buku.penulis);
    _penerbitController = TextEditingController(text: widget.buku.penerbit);
    _tahunTerbitController =
        TextEditingController(text: widget.buku.tahunTerbit?.toString() ?? '');
    _stokController =
        TextEditingController(text: widget.buku.stok?.toString() ?? '');
    _selectedKategoriId = widget.buku.kategoriId;
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    final data = await BukuService.getKategori();
    setState(() {
      _kategoriList = data;
    });
  }

  

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      // ✅ Validasi ukuran file (max 2MB)
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran gambar maksimal 2MB')),
        );
        return;
      }

      // ✅ Validasi format file
      final ext = picked.name.split('.').last.toLowerCase();
      if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format gambar harus JPG atau PNG')),
        );
        return;
      }

      _coverBytes = bytes;
      _coverName = picked.name;
      setState(() {});
    }
  }

  Future<void> _updateBuku() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final success = await BukuService.updateBuku(
      widget.buku.id!,
      _judulController.text,
      _penulisController.text,
      _penerbitController.text,
      int.parse(_tahunTerbitController.text),
      int.parse(_stokController.text),
      _selectedKategoriId!,
      _coverBytes,
      _coverName,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buku berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui buku'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    _tahunTerbitController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Judul tidak boleh kosong';
                  if (v.length > 100) return 'Judul maksimal 100 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _penulisController,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Penulis tidak boleh kosong';
                  if (v.length > 50) return 'Penulis maksimal 50 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _penerbitController,
                decoration: const InputDecoration(labelText: 'Penerbit'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Penerbit tidak boleh kosong';
                  if (v.length > 50) return 'Penerbit maksimal 50 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tahunTerbitController,
                decoration: const InputDecoration(labelText: 'Tahun Terbit'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Tahun terbit tidak boleh kosong';
                  final year = int.tryParse(v);
                  if (year == null) return 'Tahun terbit harus angka';
                  if (year < 1000 || year > currentYear) {
                    return 'Tahun harus antara 1000 dan $currentYear';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Stok tidak boleh kosong';
                  final stok = int.tryParse(v);
                  if (stok == null) return 'Stok harus angka';
                  if (stok < 0) return 'Stok tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Kategori'),
                value: _selectedKategoriId,
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem<int>(
                    value: kategori['id'],
                    child: Text(kategori['nama']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategoriId = value;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickCover,
                child: Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: _coverBytes != null
                      ? Image.memory(_coverBytes!, fit: BoxFit.cover)
                      : (widget.buku.cover != null && widget.buku.cover!.isNotEmpty)
                          ? Image.network(
                              'http://127.0.0.1:8000/storage/${widget.buku.cover!}',
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _updateBuku,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}