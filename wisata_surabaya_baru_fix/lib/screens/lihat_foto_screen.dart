import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class LihatFotoScreen extends StatefulWidget {
  final String imagePath;
  final String namaTempat;
  final String alamat;
  final String namaPengguna;
  final Function(String) onDelete;
  final Function(String, String, String) onEdit;

  const LihatFotoScreen({
    Key? key,
    required this.imagePath,
    required this.namaTempat,
    required this.alamat,
    required this.namaPengguna,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<LihatFotoScreen> createState() => _LihatFotoScreenState();
}

class _LihatFotoScreenState extends State<LihatFotoScreen> {
  late DateFormat _dateFormat;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentDate = _dateFormat.format(DateTime.now());
    final TextEditingController tempatController = TextEditingController(
      text: widget.namaTempat,
    );
    final TextEditingController alamatController = TextEditingController(
      text: widget.alamat,
    );

    void _showEditDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tempatController,
                decoration: const InputDecoration(labelText: 'Nama Tempat'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                widget.onEdit(
                  tempatController.text,
                  alamatController.text,
                  widget.imagePath,
                );
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    }

    void _confirmDelete() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(widget.imagePath);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Foto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: 'Edit Foto',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Hapus Foto',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Gambar
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Bagian Keterangan
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    widget.namaTempat,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.alamat,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailItem(
                    icon: Icons.person,
                    label: 'Diambil oleh',
                    value: widget.namaPengguna,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    icon: Icons.location_on,
                    label: 'Lokasi',
                    value: widget.alamat,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    label: 'Tanggal',
                    value: currentDate,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
