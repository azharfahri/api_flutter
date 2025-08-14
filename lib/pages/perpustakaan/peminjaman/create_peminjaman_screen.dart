import 'package:flutter/material.dart';
import 'package:api_flutter/models/buku_model.dart';
import 'package:api_flutter/services/buku_service.dart';
import 'package:api_flutter/services/peminjaman_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePeminjamen extends StatefulWidget {
  const CreatePeminjamen({super.key});

  @override
  State<CreatePeminjamen> createState() => _CreatePeminjamenState();
}

class _CreatePeminjamenState extends State<CreatePeminjamen> {
  final _formKey = GlobalKey<FormState>();
  int? _userId;
  String? _userNama;
  int? _selectedBukuId;
  List<DataBuku> _listBuku = [];

  DateTime? _tanggalPinjam;
  DateTime? _tenggat;
  String _status = 'dipinjam';
  int? _stokDipinjam;

  final dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBukuList();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_Id');
      _userNama = prefs.getString('user_Nama');
    });
  }

  Future<void> _loadBukuList() async {
    final bukuModel = await BukuService.listBuku();
    setState(() {
      _listBuku = bukuModel.data ?? [];
    });
  }

  Future<void> _pickDate(bool isPinjam) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPinjam) {
          _tanggalPinjam = picked;
        } else {
          _tenggat = picked;
        }
      });
    }
  }

  Future<void> _createPeminjamen() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalPinjam == null || _tenggat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal pinjam & tenggat harus diisi')),
      );
      return;
    }

    if (_selectedBukuId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buku harus dipilih')),
      );
      return;
    }

    if (_stokDipinjam == null || _stokDipinjam! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok dipinjam harus > 0')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await PeminjamenService.createPeminjamen(
        _selectedBukuId!,
        _tanggalPinjam!,
        _tenggat!,
        stokDipinjam: _stokDipinjam!,
        status: _status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"] ?? "Tidak ada pesan dari server",
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor:
              result["success"] == true ? Colors.green : Colors.red,
        ),
      );

      if (!result["success"]) {
        debugPrint("Error API createPeminjamen: $result");
      }

      if (result["success"]) Navigator.pop(context, true);
    } catch (e, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Exception saat createPeminjamen: $e');
      debugPrint('Stack trace: $stack');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Peminjamen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_userNama != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'User: $_userNama',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Buku',
                  border: OutlineInputBorder(),
                ),
                value: _selectedBukuId,
                items: _listBuku.map((buku) {
                  return DropdownMenuItem<int>(
                    value: buku.id!,
                    child: Text(buku.judul ?? 'Tanpa Judul'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBukuId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih buku terlebih dahulu' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Stok Dipinjam',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _stokDipinjam = int.tryParse(value),
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v <= 0)
                    return 'Stok dipinjam harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_tanggalPinjam != null
                    ? 'Tanggal Pinjam: ${dateFormat.format(_tanggalPinjam!)}'
                    : 'Pilih Tanggal Pinjam'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(true),
              ),
              ListTile(
                title: Text(_tenggat != null
                    ? 'Tenggat: ${dateFormat.format(_tenggat!)}'
                    : 'Pilih Tenggat'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(false),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
                  DropdownMenuItem(
                      value: 'dikembalikan', child: Text('Dikembalikan')),
                ],
                onChanged: (value) => setState(() => _status = value!),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Status wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPeminjamen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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
