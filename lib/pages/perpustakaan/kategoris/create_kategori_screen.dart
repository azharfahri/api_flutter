import 'package:api_flutter/models/kategori_model.dart';
import 'package:api_flutter/services/kategori_service.dart';
import 'package:flutter/material.dart';

class CreateKategori extends StatefulWidget {
  final DataKategori? kategori; // datum dari KategoriModel

  const CreateKategori({Key? key, this.kategori}) : super(key: key);

  @override
  State<CreateKategori> createState() => _CreateKategoriScreenState();
}

class _CreateKategoriScreenState extends State<CreateKategori> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();

  bool get isEdit => widget.kategori != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaController.text = widget.kategori!.nama ?? '';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _saveKategori() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (isEdit) {
      // Update
      success = await KategoriService.updateKategori(
        widget.kategori!.id!,
        _namaController.text,
      );
    } else {
      // Create
      success = await KategoriService.createKategori(
        _namaController.text,
      );
    }

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Kategori berhasil diupdate' : 'Kategori berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Gagal update kategori' : 'Gagal membuat kategori'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Kategori' : 'Create Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveKategori,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isEdit ? 'Update' : 'Simpan',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
