import 'package:flutter/material.dart';
import 'package:api_flutter/models/kategori_model.dart';
import 'package:api_flutter/services/kategori_service.dart';

class EditKategori extends StatefulWidget {
  final DataKategori kategori;
  const EditKategori({Key? key, required this.kategori}) : super(key: key);

  @override
  State<EditKategori> createState() => _EditKategoriState();
}

class _EditKategoriState extends State<EditKategori> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.kategori.nama ?? '');
  }

  Future<void> _updateKategori() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await KategoriService.updateKategori(
      widget.kategori.id!,
      _namaController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Kategori berhasil diupdate!' : 'Gagal mengupdate kategori'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Kategori"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Kategori"),
                validator: (v) => v!.isEmpty ? "Nama kategori wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateKategori,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}