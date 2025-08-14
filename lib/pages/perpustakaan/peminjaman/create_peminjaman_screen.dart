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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadUserData(), _loadBukuList()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 
                prefs.getInt('user_id') ?? 
                prefs.getInt('id');
      _userNama = prefs.getString('userNama') ?? 
                  prefs.getString('user_nama') ?? 
                  prefs.getString('nama');
    });
  }

  Future<void> _loadBukuList() async {
    try {
      final bukuModel = await BukuService.listBuku();
      setState(() {
        _listBuku = bukuModel.data ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar buku: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    if (_userId == null) {
      _userId = 1; // Fallback untuk testing, hapus di production
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menggunakan User ID default'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() => _isLoading = true);

    try {
      final result = await PeminjamenService.createPeminjamen(
        _userId!,
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
          backgroundColor: result["success"] == true ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (result["success"] == true) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Peminjamen'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_userNama != null)
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'User: $_userNama',
                                style: const TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Buku',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      value: _selectedBukuId,
                      items: _listBuku.map((buku) {
                        return DropdownMenuItem<int>(
                          value: buku.id!,
                          child: Text(
                            buku.judul ?? 'Tanpa Judul',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBukuId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Pilih buku terlebih dahulu' : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Stok Dipinjam',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                        hintText: 'Masukkan jumlah buku yang dipinjam',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _stokDipinjam = int.tryParse(value);
                      },
                      validator: (value) {
                        final v = int.tryParse(value ?? '');
                        if (v == null || v <= 0) {
                          return 'Stok dipinjam harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.blue),
                        title: Text(
                          _tanggalPinjam != null
                              ? 'Tanggal Pinjam: ${dateFormat.format(_tanggalPinjam!)}'
                              : 'Pilih Tanggal Pinjam',
                          style: TextStyle(
                            fontWeight: _tanggalPinjam != null 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                            color: _tanggalPinjam != null 
                                ? Colors.black87 
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _pickDate(true),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Card(
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.event, color: Colors.orange),
                        title: Text(
                          _tenggat != null
                              ? 'Tenggat: ${dateFormat.format(_tenggat!)}'
                              : 'Pilih Tenggat',
                          style: TextStyle(
                            fontWeight: _tenggat != null 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                            color: _tenggat != null 
                                ? Colors.black87 
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _pickDate(false),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                      value: _status,
                      items: const [
                        DropdownMenuItem(
                          value: 'dipinjam', 
                          child: Text('Dipinjam')
                        ),
                        DropdownMenuItem(
                          value: 'dikembalikan', 
                          child: Text('Dikembalikan')
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _status = value!);
                      },
                      validator: (v) => v == null || v.isEmpty 
                          ? 'Status wajib diisi' 
                          : null,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createPeminjamen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Menyimpan...'),
                                ],
                              )
                            : const Text(
                                'Simpan Peminjaman',
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w600
                                ),
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