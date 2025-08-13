import 'dart:typed_data';
import 'package:api_flutter/services/buku_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateBuku extends StatefulWidget {
  const CreateBuku({Key? key}) : super(key: key);

  @override
  State<CreateBuku> createState() => _CreateBukuState();
}

class _CreateBukuState extends State<CreateBuku> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _penulisController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _tahunTerbitController = TextEditingController();
  final _stokController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  List<Map<String, dynamic>> _kategoriList = [];
  int? _selectedKategoriId;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    final data = await BukuService.getKategori();
    setState(() {
      _kategoriList = data;
    });
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  Future<void> _createBuku() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    if (_imageBytes == null || _imageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
      return;
    }

    final success = await BukuService.createBuku(
      _judulController.text,
      _penulisController.text,
      _penerbitController.text,
      int.parse(_tahunTerbitController.text),
      int.parse(_stokController.text),
      _selectedKategoriId!,
      _imageBytes!,
      _imageName!,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buku berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat buku'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Buku')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) =>
                    v!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _penulisController,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator: (v) =>
                    v!.isEmpty ? 'Penulis tidak boleh kosong' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _penerbitController,
                decoration: const InputDecoration(labelText: 'Penerbit'),
                validator: (v) =>
                    v!.isEmpty ? 'Penerbit tidak boleh kosong' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tahunTerbitController,
                decoration: const InputDecoration(labelText: 'Tahun Terbit'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'Tahun terbit tidak boleh kosong' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'Stok tidak boleh kosong' : null,
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
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pilih Gambar'),
                  ),
                  const SizedBox(width: 8),
                  _imageName != null
                      ? Expanded(child: Text(_imageName!))
                      : const Text('Belum ada gambar')
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _createBuku,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
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
