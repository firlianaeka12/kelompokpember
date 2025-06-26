import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wisata_model.dart';
import '../service/wisata_service.dart';

class WisataFormScreen extends StatefulWidget {
  final String type; // 'favorit' atau 'riwayat'
  final WisataModel? wisata; // null untuk add, ada value untuk edit

  const WisataFormScreen({Key? key, required this.type, this.wisata})
    : super(key: key);

  @override
  State<WisataFormScreen> createState() => _WisataFormScreenState();
}

class _WisataFormScreenState extends State<WisataFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final WisataService _wisataService = WisataService();

  late TextEditingController _namaTempatController;
  late TextEditingController _alamatController;
  late TextEditingController _deskripsiController;
  late TextEditingController _gambarController;
  late TextEditingController _hargaTiketController;

  bool _isLoading = false;
  bool get _isEditing => widget.wisata != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _namaTempatController = TextEditingController(
      text: widget.wisata?.namaTempat ?? '',
    );
    _alamatController = TextEditingController(
      text: widget.wisata?.alamat ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.wisata?.deskripsi ?? '',
    );
    _gambarController = TextEditingController(
      text: widget.wisata?.gambar ?? '',
    );
    _hargaTiketController = TextEditingController(
      text: widget.wisata?.hargaTiket.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Wisata' : 'Tambah Wisata'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview gambar
            if (_gambarController.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _gambarController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text('Gambar tidak dapat dimuat'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Nama Tempat
            TextFormField(
              controller: _namaTempatController,
              decoration: InputDecoration(
                labelText: 'Nama Tempat Wisata',
                prefixIcon: const Icon(Icons.place),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tempat tidak boleh kosong';
                }
                if (value.trim().length < 3) {
                  return 'Nama tempat minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Alamat
            TextFormField(
              controller: _alamatController,
              decoration: InputDecoration(
                labelText: 'Alamat',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                if (value.trim().length < 10) {
                  return 'Deskripsi minimal 10 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // URL Gambar
            TextFormField(
              controller: _gambarController,
              decoration: InputDecoration(
                labelText: 'URL Gambar',
                prefixIcon: const Icon(Icons.image),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {}); // Refresh preview gambar
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'URL gambar tidak boleh kosong';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasAbsolutePath) {
                  return 'URL gambar tidak valid';
                }
                return null;
              },
              onChanged: (value) {
                // Auto refresh preview setelah delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) setState(() {});
                });
              },
            ),
            const SizedBox(height: 16),

            // Harga Tiket
            TextFormField(
              controller: _hargaTiketController,
              decoration: InputDecoration(
                labelText: 'Harga Tiket (Rupiah)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Harga tiket tidak boleh kosong';
                }
                final harga = int.tryParse(value);
                if (harga == null || harga <= 0) {
                  return 'Harga tiket harus berupa angka positif';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Tombol Submit
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Update Wisata' : 'Simpan Wisata',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final wisataData = WisataModel(
        id: widget.wisata?.id,
        namaTempat: _namaTempatController.text.trim(),
        alamat: _alamatController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        gambar: _gambarController.text.trim(),
        hargaTiket: int.parse(_hargaTiketController.text.trim()),
      );

      if (_isEditing) {
        // Update existing wisata
        if (widget.type == 'favorit') {
          await _wisataService.updateFavoritWisata(
            widget.wisata!.id!,
            wisataData,
          );
        } else {
          await _wisataService.updateRiwayatWisata(
            widget.wisata!.id!,
            wisataData,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wisata berhasil diupdate'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new wisata
        if (widget.type == 'favorit') {
          await _wisataService.addFavoritWisata(wisataData);
        } else {
          await _wisataService.addRiwayatWisata(wisataData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wisata berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Kembali ke halaman sebelumnya
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaTempatController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    _gambarController.dispose();
    _hargaTiketController.dispose();
    super.dispose();
  }
}
