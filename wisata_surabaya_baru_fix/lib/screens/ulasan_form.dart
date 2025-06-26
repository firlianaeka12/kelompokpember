import 'package:flutter/material.dart';
import '../models/ulasan.dart';
import '../service/ulasan_service.dart';

class UlasanFormScreen extends StatefulWidget {
  final Ulasan? ulasan;
  final int wisataId;
  final String wisataNama;
  final int userId; // Tambahkan parameter userId

  const UlasanFormScreen({
    Key? key,
    this.ulasan,
    required this.wisataId,
    required this.wisataNama,
    required this.userId, // Tambahkan ini
  }) : super(key: key);

  @override
  _UlasanFormScreenState createState() => _UlasanFormScreenState();
}

class _UlasanFormScreenState extends State<UlasanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _komentarController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.ulasan != null) {
      _komentarController.text = widget.ulasan!.komentar;
      _rating = widget.ulasan!.rating.toDouble();
    }
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _simpanUlasan() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap beri rating dan komentar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Selalu buat ulasan baru tanpa cek duplikat
      await UlasanService.buatUlasan(
        userId: widget.userId,
        wisataId: widget.wisataId,
        wisataNama: widget.wisataNama,
        rating: _rating.toInt(),
        komentar: _komentarController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil ditambahkan')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ulasan == null ? 'Buat Ulasan' : 'Edit Ulasan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.wisataNama,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Rating:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      size: 40,
                      color: index < _rating ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = (index + 1).toDouble();
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _komentarController,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  border: OutlineInputBorder(),
                  hintText: 'Bagikan pengalaman Anda...',
                ),
                maxLines: 5,
                minLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi komentar';
                  }
                  if (value.length < 10) {
                    return 'Komentar terlalu pendek';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _simpanUlasan,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.ulasan == null
                              ? 'Simpan Ulasan'
                              : 'Perbarui Ulasan',
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
