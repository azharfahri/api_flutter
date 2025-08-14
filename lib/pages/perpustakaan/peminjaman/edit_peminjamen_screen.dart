import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api_flutter/models/peminjaman_model.dart';
import 'package:api_flutter/services/peminjaman_service.dart';
import 'package:intl/intl.dart';

class EditPeminjamen extends StatefulWidget {
  final DataPeminjaman peminjamen;
  const EditPeminjamen({Key? key, required this.peminjamen}) : super(key: key);

  @override
  State<EditPeminjamen> createState() => _EditPeminjamenState();
}

class _EditPeminjamenState extends State<EditPeminjamen> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'dipinjam';
  DateTime? _tanggalPengembalian;
  int? _stokDipinjam;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.peminjamen.status ?? 'dipinjam';
    _tanggalPengembalian = widget.peminjamen.tanggalPengembalian;
    _stokDipinjam = widget.peminjamen.stokDipinjam ?? 1;
  }

  Future<void> _pickTanggalPengembalian() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPengembalian ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalPengembalian = picked;
      });
    }
  }

  Future<void> _updatePeminjamen() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await PeminjamenService.updatePeminjamen(
      widget.peminjamen.id!,
      widget.peminjamen.userId!,
      widget.peminjamen.bukuId!,
      widget.peminjamen.tanggalPinjam!,
      widget.peminjamen.tenggat!,
      _stokDipinjam!,
      _tanggalPengembalian,
      _status,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Peminjamen berhasil diupdate!'
              : 'Gagal mengupdate peminjamen',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Peminjamen")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _stokDipinjam.toString(),
                decoration: const InputDecoration(
                  labelText: 'Stok Dipinjam',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => _stokDipinjam = int.tryParse(v) ?? 1,
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val <= 0)
                    return 'Isi jumlah stok dipinjam valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
                  DropdownMenuItem(
                      value: 'dikembalikan', child: Text('Dikembalikan')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
                validator: (v) =>
                    v == null || v.isEmpty ? 'Status wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pengembalian',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _tanggalPengembalian != null
                      ? _dateFormat.format(_tanggalPengembalian!)
                      : '',
                ),
                onTap: _pickTanggalPengembalian,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePeminjamen,
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